-- ============================================================
-- Müzem — Migration 0004: hero images for museum and artifacts
-- All URLs point to Wikipedia Commons (stable, CC-licensed).
-- ============================================================

-- Add image_url column to museums (artifacts already had one from 0002)
alter table public.museums add column if not exists image_url text;

-- Museum hero
update public.museums
set image_url = 'https://upload.wikimedia.org/wikipedia/commons/0/06/Topkap%C4%B1_-_01.jpg'
where name = 'Topkapi Sarayi Muzesi';

-- Artifact images, mapped by qr_payload
update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/8/8f/Topkapi_Knife_04_1993.jpg'
where qr_payload = 'art-topkapi-hancer';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Spoonmaker%27s_Diamond5%2C_Topkapi_Palace%2C_Istanbul_2023.jpg/1920px-Spoonmaker%27s_Diamond5%2C_Topkapi_Palace%2C_Istanbul_2023.jpg'
where qr_payload = 'art-kasikci-elmas';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/e/e5/Calligraphic_Plate_1849_%28Ottoman_Period_%28Osmanl%C4%B1_%C4%B0mparatorlu%C4%9Fu%29%29.jpg'
where qr_payload = 'art-hirka-saadet';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/a/a7/SanaaQuoranDoubleVersions.jpg'
where qr_payload = 'art-kuran-elyaz';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/6/6e/Bellini%2C_Gentile_-_Sultan_Mehmet_II.jpg'
where qr_payload = 'art-fatih-portre';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Turkey%3B_Iznik_-_Two_Tiles_-_Google_Art_Project.jpg/1920px-Turkey%3B_Iznik_-_Two_Tiles_-_Google_Art_Project.jpg'
where qr_payload = 'art-selcuklu-cini';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/9/95/9Double-Niche_Carpet_LACMA_M.2004.32_%28cropped%29.jpg'
where qr_payload = 'art-anadolu-hali';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Sphinx_Gate%2C_Hattusa_01.jpg/1920px-Sphinx_Gate%2C_Hattusa_01.jpg'
where qr_payload = 'art-hitit-heykel';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/e/e1/Xerxes_Cuneiform_Van.JPG'
where qr_payload = 'art-sumer-tablet';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/6/6d/Christ_Pantocrator_mosaic_from_Hagia_Sophia_2744_x_2900_pixels_3.1_MB.jpg'
where qr_payload = 'art-bizans-mozayik';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/b/b1/Tughra_Orhan_I.jpg'
where qr_payload = 'art-padisah-tugra';

update public.artifacts set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/c/c0/Lambert_Wyts_-_Agha_of_the_Janissaries_and_a_B%C3%B6l%C3%BCk_of_the_Janissaries.jpg'
where qr_payload = 'art-yenicerikilic';
