-- ============================================================
-- Müzem — Migration 0006: exhibition images + more exhibitions
-- ============================================================

-- Image URL column for exhibitions
alter table public.exhibitions add column if not exists image_url text;

-- Set images for the two original Topkapı exhibitions
update public.exhibitions set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/e/e7/Istanbul.Topkapi084.jpg'
where title = 'Osmanli Hazineleri';

update public.exhibitions set image_url =
  'https://upload.wikimedia.org/wikipedia/commons/0/06/Topkap%C4%B1_-_01.jpg'
where title = 'Harem Daireleri';

-- Add three more Topkapı-themed exhibitions
with t as (
  select id from public.museums where name = 'Topkapi Sarayi Muzesi' limit 1
)
insert into public.exhibitions (museum_id, title, start_date, end_date, description, image_url)
select t.id, e.title, e.start_date::date, e.end_date::date, e.description, e.image_url
from t
cross join (values
  (
    'Padisah Portreleri Galerisi',
    '2026-06-01', '2026-12-31',
    'Osmanli padisahlarinin Avrupali ressamlar tarafindan yapilmis portreleri. Bellini''den Vanmour''a uzanan bir koleksiyon.',
    'https://upload.wikimedia.org/wikipedia/commons/3/3b/Portrait_of_Sultan_Ahmed_III_%281673%E2%80%931736%29%2C_three-quarter-length%2C_standing%2C_with_a_view_onto_the_Bosphorus_and_the_Hagia_Sophia_by_Jean-Baptiste_Vanmour.jpg'
  ),
  (
    'Osmanli Minyatur Sanati',
    '2026-04-15', '2026-10-15',
    'Saray nakkashanesinden cikan minyatur eserler. Tarihi olaylarin ve sehzadelerin gunluk yasamlarinin gorsel kayitlari.',
    'https://upload.wikimedia.org/wikipedia/commons/e/ef/Ottoman_miniature_painters.jpg'
  ),
  (
    'Iznik Cinileri Koleksiyonu',
    '2026-03-01', '2026-11-30',
    '16-17. yuzyil Iznik atolyelerinden cikan, lacivert ve mercan kirmizisi motiflerle islenmis cini sanatinin baskorleri.',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Turkey%3B_Iznik_-_Two_Tiles_-_Google_Art_Project.jpg/1920px-Turkey%3B_Iznik_-_Two_Tiles_-_Google_Art_Project.jpg'
  ),
  (
    'Kutsal Emanetler Bolumu',
    '2026-01-01', '2026-12-31',
    'Hz. Muhammed''e (s.a.v.) ve sahabeye ait oldugu kabul edilen kutsal emanetlerin sergilendigi daire. Hirka-i Saadet ve Sancak-i Serif burada bulunur.',
    'https://upload.wikimedia.org/wikipedia/commons/e/e5/Calligraphic_Plate_1849_%28Ottoman_Period_%28Osmanl%C4%B1_%C4%B0mparatorlu%C4%9Fu%29%29.jpg'
  )
) as e(title, start_date, end_date, description, image_url);
