-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q3help;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
 SELECT MAX(era)
 FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear from people where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear from people where namefirst like '% %' order by namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*) from people group by birthyear order by birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*) from people group by birthyear  having avg(height) > 70 order by birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, halloffame.playerid, yearid from halloffame, people where people.playerid = halloffame.playerid and inducted='Y' order by yearid DESC, halloffame.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q2i.playerid, schools.schoolid, yearid 
  from q2i, schools, collegeplaying 
  where collegeplaying.playerid = q2i.playerid and collegeplaying.schoolid = schools.schoolid and schoolstate = 'CA' 
  order by yearid DESC, schools.schoolid, q2i.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, namefirst, namelast, schoolid 
  from q2i 
    left outer join collegeplaying
    on q2i.playerid = collegeplaying.playerid
  order by q2i.playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerid, namefirst, namelast, yearid, SUM(H+H2B+2*H3B+3*HR)*1.0/SUM(AB) as slg
  from people, batting 
  where people.playerid=batting.playerid
  group by people.playerid, namefirst, namelast, yearid, teamid
  having SUM(AB) > 50
  order by slg DESC, yearid, people.playerid
  limit 10
;


CREATE VIEW q3help(playerid, namefirst, namelast, lslg)
AS
  SELECT people.playerid, namefirst, namelast, SUM(H+H2B+2*H3B+3*HR)*1.0/SUM(AB) as lslg
  from people, batting 
  where people.playerid=batting.playerid
  group by people.playerid, namefirst, namelast
  having SUM(AB) > 50
  order by lslg DESC, people.playerid
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT *
  from q3help
  limit 10
;



-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  from q3help where lslg > (
    SELECT lslg from q3help where playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
  from salaries
  group by yearid
  order by yearid
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

DROP VIEW IF EXISTS q4iih;

CREATE VIEW q4iih(binid, low, high) 
AS
  SELECT binid, min(salary) + (max(salary)-min(salary)) * binid /10.0, min(salary) + (max(salary)-min(salary)) * (binid+1)/10.0 + (binid=9)
  from binids, salaries
  where yearid = 2016
  group by binid
;


-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, low, high, count(*)
  from q4iih, salaries where salary >= low and salary < high and yearid = 2016
  group by binid, low, high
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT year2.yearid, min(year2.salary)-min(year1.salary), max(year2.salary)-max(year1.salary), avg(year2.salary)-avg(year1.salary)
  from salaries as year1, salaries as year2
  where year1.yearid = year2.yearid-1
  group by year2.yearid
  order by year2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT salaries.playerid, namefirst, namelast, salary, yearid
  from salaries, people
  where salaries.playerid = people.playerid and salaries.yearid = 2000 and salaries.salary = (select MAX(salary) from salaries where yearid=2000 group by yearid)
  union all
  SELECT salaries.playerid, namefirst, namelast, salary, yearid
  from salaries, people
  where salaries.playerid = people.playerid and salaries.yearid = 2001 and salaries.salary = (select MAX(salary) from salaries where yearid=2001 group by yearid)

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT allstarfull.teamid, max(salary) - min(salary)
  from salaries, people, allstarfull where salaries.playerid = people.playerid and people.playerid = allstarfull.playerid and salaries.yearid=2016 and allstarfull.yearid=2016
  group by allstarfull.teamid
;

