-- Find the crime scene report for the murder

SELECT *
  FROM crime_scene_report
 WHERE city = 'SQL City' AND 
       date = '20180115' AND 
       type = 'murder';
       
-- Find the witnesses

SELECT p.id,
       p.name,
       p.license_id,
       p.address_number,
       p.address_street_name,
       p.ssn
  FROM person p
 WHERE (p.address_street_name = 'Northwestern Dr' AND 
        p.address_number = (
                               SELECT MAX(address_number) 
                                 FROM person
                                WHERE address_street_name = 'Northwestern Dr'
                           )
       ) OR 
       (p.address_street_name = 'Franklin Ave' AND 
        p.name LIKE 'Annabel%');
        
-- Look at the interviews of the witnesses

SELECT *
  FROM interview
 WHERE person_id IN (
           SELECT p.id
             FROM person p
            WHERE (p.address_street_name = 'Northwestern Dr' AND 
                   p.address_number = (
                                          SELECT MAX(address_number) 
                                            FROM person
                                           WHERE address_street_name = 'Northwestern Dr'
                                      )
                  ) OR 
                  (p.address_street_name = 'Franklin Ave' AND 
                   p.name LIKE 'Annabel%') 
       );
       
-- Investigate gym membership information

SELECT m.*,
       c.*
  FROM get_fit_now_member m
       INNER JOIN
       get_fit_now_check_in c ON m.id = c.membership_id
 WHERE c.membership_id LIKE '48Z%' AND 
       c.check_in_date = '20180109';
       
-- Look at the driver's licenses and car plates

SELECT d.*,
       p.*
  FROM drivers_license d
       INNER JOIN
       person p ON d.id = p.license_id
 WHERE d.plate_number LIKE '%H42W%' AND 
       p.name IN ('Jeremy Bowers', 'Joe Germuska');
       
-- Jeremy Bowers is the murderer, but who hired him?

SELECT *
  FROM interview
 WHERE person_id = '67318';
 -- Murderer was hired by a woman with money.
-- Height: 5'5 (65") or 5'7 (67").
-- Red hair
-- Drives a Tesla Model S
-- Attended SQL Symphony Concert three times in Dec 2017.
WITH rich_suspects AS (
    SELECT p.id AS person_id,
           p.name,
           i.annual_income
      FROM drivers_license dl
           INNER JOIN
           person p ON dl.id = p.license_id
           INNER JOIN
           income i ON p.ssn = i.ssn
     WHERE dl.gender = 'female' AND 
           dl.hair_color = 'red' AND 
           dl.car_make = 'Tesla' AND 
           dl.car_model = 'Model S' AND 
           dl.height BETWEEN 64 AND 68
),
symphony_attenders AS (
    SELECT person_id,
           COUNT( * ) AS n_checkins
      FROM facebook_event_checkin
     WHERE event_name = 'SQL Symphony Concert' AND 
           date REGEXP '^201712'
     GROUP BY person_id
    HAVING n_checkins = 3
)
SELECT rs.name,
       rs.annual_income
  FROM rich_suspects rs
       INNER JOIN
       symphony_attenders sa ON rs.person_id = sa.person_id;
       -- Miranda Priestly hired Jeremy Bowers
