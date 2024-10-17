-- CREATE A DATABASE FOR MOBILE USER'S USAGE AND BEHAVIOUR ANALYSIS
DROP DATABASE IF EXISTS mobileuserinsights;
CREATE DATABASE mobileUserInsights;

use mobileUserInsights;

DROP TABLE IF EXISTS user_data;
CREATE TABLE user_data
(
user_id INT PRIMARY KEY,
device VARCHAR(100),
operating_system VARCHAR(50), --  (iOS or Android)
app_usage INT, -- app usage time in minute/day
screen_time DECIMAL(5,2), -- screen on time in hours/day
battery_drain INT, -- maH/day
total_apps INT, -- number of apps installed
data_usage INT, -- mb/day
age INT,
gender VARCHAR(10),
user_behavior INT  -- Classification of user behavior based on usage patterns
);

-- USER ENGAGEMENT TIME ACROSS DIFFERENT DEVICES
SELECT device, SUM(app_usage) DIV 60 AS hours
FROM user_data
GROUP BY device
ORDER BY hours;

-- MOST POPULAR MOBILE DEVICE BRAND AMONG USERS
SELECT device
FROM user_data
GROUP BY device
ORDER BY COUNT(device) DESC
LIMIT 1;

-- USERS WITH ANDROID VS IOS
SELECT operating_system, count(*) as Total
FROM user_data
WHERE operating_system IN ('Android','iOS')
GROUP BY operating_system;

--  AVERAGE SCREEN TIME FOR USERS ON IOS COMPARED TO ANDROID
SELECT operating_system, ROUND(AVG(screen_time),2) as 'Average Screen Time'
FROM user_data
WHERE operating_system IN ('Android','iOS')
GROUP BY operating_system;

-- DISTRIBUTION OF APP USAGE TIME ACROSS DIFFERENT AGE GROUPS

SELECT CASE
WHEN age BETWEEN 18 AND 25 THEN "Young Gen"
WHEN age BETWEEN 26 AND 45 THEN "Adult Gen"
WHEN age > 45 THEN "Middle Aged"
ELSE "Other"
END AS Age_group,
ROUND(SUM(app_usage) * 100.0 / (SELECT SUM(app_usage) FROM user_data)) as Usage_Percentage
FROM user_data
GROUP BY Age_group;

-- USERS WITH HIGHEST NUMBER OF INSTALLED APPS, AND CORRELATION WITH THEIR DATA USAGE
SELECT user_id, data_usage
FROM user_data
WHERE total_apps = (SELECT MAX(total_apps) FROM user_data);

-- NUMBER OF INSTALLED APPS AND AVERAGE SCREEN TIME FOR EACH GROUP
SELECT total_apps, AVG(screen_time) AS avg_screen_time
FROM user_data
GROUP BY total_apps
ORDER BY total_apps DESC;

-- AVERAGE APP USAGE TIME PER DAY FOR USERS WITH HIGH SCREEN TIME
SELECT AVG(app_usage) DIV 60 average_app_usage
FROM user_data
WHERE screen_time > 6;  -- if screen time is more than 6 hrs then we assume it as high screen time

-- APP USAGE VARIATION BY GENDER
SELECT gender, SUM(app_usage) DIV 60 app_usage_hours,
ROUND(SUM(app_usage) * 100 / (SELECT SUM(app_usage) FROM user_data)) as percentage
FROM user_data
GROUP BY gender;

-- RELATIONSHIP BETWEEN SCREEN TIME AND BATTERY DRAIN
SELECT screen_time "Screen Time (hours)", ROUND(AVG(battery_drain)) "Battery Drain MaH"
FROM user_data
GROUP BY screen_time
ORDER BY screen_time;


-- USER WITH HIGHEST BATTERY DRAIN
WITH highestBatteryDrain as
(
select Max(battery_drain) as highestDrain
FROM user_data
)
SELECT user_id, device, operating_system, ROUND(app_usage DIV 60) app_usage, screen_time
FROM user_data,highestBatteryDrain
WHERE battery_drain = highestDrain;


-- USERS WITH HIGH DATA USAGE AND LOW SCREEN TIME
SELECT user_id, data_usage, screen_time, app_usage, total_apps
FROM user_data
WHERE data_usage > 1000  -- "high data usage" threshold 
AND screen_time < 4  -- "low screen time" threshold 
ORDER BY data_usage DESC;

-- APP USAGE PERCENTAGE OF HEAVY USER
WITH TotalUsers AS (
SELECT COUNT(user_behavior) AS total_count
FROM user_data
)
SELECT ROUND(COUNT(user_behavior) * 100.0 / (SELECT total_count FROM TotalUsers)) AS percentage
FROM user_data
WHERE user_behavior = 5;

-- AVERAGE BATTERY DRAIN FOR EACH USER BEHAVIOR CLASSIFICATION
SELECT user_behavior, AVG(battery_drain) AS avg_battery_drain
FROM user_data
GROUP BY user_behavior
ORDER BY user_behavior DESC;

-- AVERAGE SCREEN TIME, APP USAGE, AND BATTERY DRAIN FOR EACH AGE GROUP
SELECT CASE
WHEN age BETWEEN 18 AND 25 THEN "Young Gen (18-25)"
WHEN age BETWEEN 26 AND 45 THEN "Adult Gen (26 - 25)"
WHEN age > 45 THEN "Middle Aged (45 & above)"
ELSE "Other"
END AS Age_group,
       AVG(screen_time) AS avg_screen_time, 
       AVG(app_usage) AS avg_app_usage, 
       AVG(battery_drain) AS avg_battery_drain
FROM user_data
GROUP BY Age_group
ORDER BY age_group ASC;



