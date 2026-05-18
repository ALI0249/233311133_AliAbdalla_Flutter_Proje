-- ============================================================
-- Müzem — Migration 0005: seed test users
-- Creates three authenticated accounts so login works without going
-- through the in-app register flow. Idempotent: safe to re-run.
--
-- Accounts:
--   ziyaretci@muzem.test  /  Ziyaretci123!   (role: ziyaretci)
--   personel@muzem.test   /  Personel123!    (role: personel)
--   admin@muzem.test      /  Admin123!       (role: admin)
--
-- NOTE: pgcrypto's crypt/gen_salt live in the `extensions` schema in
-- modern Supabase setups. If your project has them in `public` instead,
-- replace `extensions.crypt`/`extensions.gen_salt` with `crypt`/`gen_salt`.
-- ============================================================

do $$
declare
  v_user_id uuid;
  v_row record;
begin
  for v_row in
    select * from (values
      ('ziyaretci@muzem.test', 'Ziyaretci123!', 'Ziyaretci Test', 'ziyaretci'),
      ('personel@muzem.test',  'Personel123!',  'Personel Test',  'personel'),
      ('admin@muzem.test',     'Admin123!',     'Admin Test',     'admin')
    ) as t(email, password, full_name, role)
  loop
    select id into v_user_id from auth.users where email = v_row.email;

    if v_user_id is null then
      v_user_id := gen_random_uuid();

      -- Create the auth user
      insert into auth.users (
        instance_id, id, aud, role,
        email, encrypted_password,
        email_confirmed_at,
        created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data,
        confirmation_token, recovery_token,
        email_change_token_new, email_change
      ) values (
        '00000000-0000-0000-0000-000000000000',
        v_user_id,
        'authenticated',
        'authenticated',
        v_row.email,
        extensions.crypt(v_row.password, extensions.gen_salt('bf')),
        now(),
        now(), now(),
        jsonb_build_object(
          'provider','email',
          'providers', jsonb_build_array('email')
        ),
        jsonb_build_object('full_name', v_row.full_name),
        '', '', '', ''
      );

      -- Supabase requires an identity row per provider for sign-in to work
      insert into auth.identities (
        id, user_id, identity_data, provider, provider_id,
        last_sign_in_at, created_at, updated_at
      ) values (
        gen_random_uuid(),
        v_user_id,
        jsonb_build_object(
          'sub', v_user_id::text,
          'email', v_row.email,
          'email_verified', true
        ),
        'email',
        v_user_id::text,
        now(), now(), now()
      );
    else
      -- User already exists — refresh password + ensure confirmed
      update auth.users
        set encrypted_password = extensions.crypt(
              v_row.password,
              extensions.gen_salt('bf')
            ),
            email_confirmed_at = coalesce(email_confirmed_at, now()),
            raw_user_meta_data = jsonb_set(
              coalesce(raw_user_meta_data, '{}'::jsonb),
              '{full_name}',
              to_jsonb(v_row.full_name)
            )
        where id = v_user_id;
    end if;

    -- Upsert the profile with the correct role
    -- (the handle_new_user trigger inserts a default 'ziyaretci' row;
    --  this either creates it if missing or updates the role to match)
    insert into public.profiles (id, full_name, role)
    values (v_user_id, v_row.full_name, v_row.role)
    on conflict (id) do update set
      full_name = excluded.full_name,
      role = excluded.role;
  end loop;
end $$;

-- Verify
select u.email,
       u.email_confirmed_at is not null as confirmed,
       p.role,
       p.full_name
from auth.users u
left join public.profiles p on p.id = u.id
where u.email in (
  'ziyaretci@muzem.test',
  'personel@muzem.test',
  'admin@muzem.test'
)
order by case p.role
  when 'admin' then 1
  when 'personel' then 2
  when 'ziyaretci' then 3
  else 4
end;
