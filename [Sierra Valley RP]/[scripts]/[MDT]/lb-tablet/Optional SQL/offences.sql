-- Sierra Valley RP Penal Code Import
-- Generated for lb-tablet MDT System

-- Drop existing data to start fresh (comment out if you want to keep existing data)
-- DELETE FROM `lbtablet_police_offences`;
-- DELETE FROM `lbtablet_police_offences_categories`;

-- Create Categories Table
CREATE TABLE IF NOT EXISTS `lbtablet_police_offences_categories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Categories
INSERT IGNORE INTO `lbtablet_police_offences_categories` (`id`, `title`) VALUES
    (1, 'Traffic Violations'),
    (2, 'Misdemeanors'),
    (3, 'Felonies'),
    (4, 'Wildlife Misdemeanors'),
    (5, 'Wildlife Felonies');

-- Create Offences Table
CREATE TABLE IF NOT EXISTS `lbtablet_police_offences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int(10) unsigned NOT NULL,
  `class` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `fine` int(10) unsigned NOT NULL DEFAULT 0,
  `jail_time` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `category_id` (`category_id`,`class`,`title`),
  CONSTRAINT `lbtablet_police_offences_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `lbtablet_police_offences_categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=500 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TRAFFIC VIOLATIONS - 100 SERIES
-- ============================================

INSERT IGNORE INTO `lbtablet_police_offences` (`id`, `category_id`, `class`, `title`, `description`, `fine`, `jail_time`) VALUES
    (101, 1, 'misdemeanor', 'Reckless Driving', 'Operating a vehicle with willful disregard for safety.', 1500, 10),
    (102, 1, 'misdemeanor', 'Driving Without a License', 'Operating a vehicle without a valid driver\'s license.', 750, 5),
    (103, 1, 'infraction', 'Driving Without Headlights/Tail Lights', 'Failing to use required lighting during hours of darkness.', 150, 0),
    (104, 1, 'infraction', 'Excessive Vehicle Noise', 'Creating unlawful exhaust or engine noise.', 200, 0),
    (105, 1, 'infraction', 'Failure to Obey Traffic Control Device', 'Ignoring stop signs, red lights, or posted traffic devices.', 250, 0),
    (106, 1, 'infraction', 'Failure to Maintain Lanes', 'Unsafe or improper lane deviation.', 500, 0),
    (107, 1, 'misdemeanor', 'Failure to Yield to Pedestrian', 'Not yielding to pedestrians in crosswalks.', 250, 5),
    (108, 1, 'misdemeanor', 'Failure to Yield to Emergency Vehicle', 'Not yielding to lights-and-siren emergency vehicles.', 500, 5),
    (109, 1, 'infraction', 'Illegal U-Turn', 'Making a prohibited turning maneuver.', 200, 0),
    (110, 1, 'infraction', 'Illegal Parking', 'Parking in a prohibited or restricted area.', 250, 0),
    (111, 1, 'infraction', 'Impeding Flow of Traffic', 'Driving or stopping in a manner that disrupts traffic.', 400, 0),
    (112, 1, 'misdemeanor', 'Driving Without Insurance', 'Operating a vehicle without required financial responsibility.', 450, 5),
    (113, 1, 'infraction', 'Speeding 10-19 MPH Over', 'Exceeding posted speed by 10-19 mph.', 150, 0),
    (114, 1, 'infraction', 'Speeding 20-29 MPH Over', 'Exceeding posted speed by 20-29 mph.', 250, 0),
    (115, 1, 'misdemeanor', 'Speeding 30+ MPH Over', 'Exceeding posted speed by 30 mph or more.', 500, 5),
    (116, 1, 'misdemeanor', 'Unlawful Vehicle Modification', 'Operating a vehicle with illegal or unsafe mods including window tint, oversized exhaust, or neon underglow.', 500, 5),
    (117, 1, 'misdemeanor', 'Unroadworthy Vehicle', 'Vehicle in condition unsafe for roadway use.', 350, 5),
    (118, 1, 'misdemeanor', 'Improper Use of Motor Vehicle', 'Using a vehicle in a manner not intended or unsafe.', 400, 5),
    (119, 1, 'misdemeanor', 'DUI (1st Offense)', 'Operating a vehicle under the influence of drugs or alcohol.', 2500, 10),
    (120, 1, 'misdemeanor', 'DUI (2nd Offense)', 'Second DUI conviction within 5 years.', 3500, 15),
    (121, 1, 'felony', 'DUI (3rd Offense)', 'Third DUI conviction within 5 years.', 5000, 20),
    (122, 1, 'misdemeanor', 'Driving While Suspended (1st Offense)', 'Operating a vehicle while license is suspended, canceled, or revoked.', 1500, 5),
    (123, 1, 'misdemeanor', 'Driving While Suspended (2nd Offense)', 'Second conviction within 5 years.', 2500, 10),
    (124, 1, 'felony', 'Driving While Suspended (3rd Offense)', 'Third conviction within 5 years.', 5000, 20),
    (125, 1, 'misdemeanor', 'Abandoned Vehicle', 'Leaving a vehicle unattended on public property for extended periods.', 250, 5),
    (126, 1, 'misdemeanor', 'Illegally Parked Vehicle', 'Parking in areas violating municipal codes or restrictions.', 150, 5);

-- ============================================
-- MISDEMEANORS - 200 SERIES
-- ============================================

INSERT IGNORE INTO `lbtablet_police_offences` (`id`, `category_id`, `class`, `title`, `description`, `fine`, `jail_time`) VALUES
    (201, 2, 'misdemeanor', 'Possession of Burglary Tools', 'Possession of tools commonly used for burglary with unlawful intent.', 1000, 5),
    (202, 2, 'misdemeanor', 'Disorderly Conduct', 'Causing a public disturbance or engaging in disruptive behavior.', 500, 5),
    (203, 2, 'misdemeanor', 'Disturbing the Peace', 'Loud or disruptive behavior affecting public order.', 400, 5),
    (204, 2, 'misdemeanor', 'Public Intoxication', 'Appearing in public while intoxicated to the degree of being a danger.', 300, 5),
    (205, 2, 'misdemeanor', 'Loitering', 'Remaining in an area without lawful purpose.', 150, 5),
    (206, 2, 'misdemeanor', 'Jaywalking', 'Improperly crossing a roadway.', 100, 5),
    (207, 2, 'misdemeanor', 'Assault', 'Unlawfully placing another in fear of imminent bodily harm.', 750, 5),
    (208, 2, 'misdemeanor', 'Aiding & Abetting', 'Assisting another in committing a crime.', 1000, 5),
    (209, 2, 'misdemeanor', 'Battery', 'Unlawful physical force against another person.', 900, 5),
    (210, 2, 'misdemeanor', 'Breaking & Entering', 'Entering property unlawfully without force.', 1200, 10),
    (211, 2, 'misdemeanor', 'Brandishing a Firearm', 'Displaying a firearm in a threatening manner.', 1500, 10),
    (212, 2, 'misdemeanor', 'Bribery', 'Attempting to influence an official through unlawful payment.', 2000, 10),
    (213, 2, 'misdemeanor', 'Contempt of Court', 'Disrupting or disobeying court authority.', 1000, 5),
    (214, 2, 'misdemeanor', 'Destruction of Property', 'Damaging property not belonging to you.', 800, 5),
    (215, 2, 'misdemeanor', 'Drug Possession Class C', 'Possession of low-level illegal substances.', 600, 5),
    (216, 2, 'misdemeanor', 'Drug Possession Class B', 'Possession of moderate illegal substances.', 1000, 5),
    (217, 2, 'misdemeanor', 'Drug Possession Class A', 'Possession of high-level illegal substances.', 2000, 5),
    (219, 2, 'misdemeanor', 'Failure to Identify', 'Refusal to provide lawful identification.', 400, 5),
    (220, 2, 'misdemeanor', 'Failure to Comply', 'Refusing lawful orders from law enforcement.', 600, 5),
    (221, 2, 'misdemeanor', 'False Reporting', 'Knowingly providing false information to emergency services.', 1000, 5),
    (222, 2, 'misdemeanor', 'Filing a False Complaint', 'Making a knowingly false complaint against another.', 750, 5),
    (223, 2, 'misdemeanor', 'Indecent Exposure', 'Exposing intimate body parts in public.', 900, 5),
    (224, 2, 'misdemeanor', 'Illegal Street Racing', 'Participating in unlawful vehicle racing.', 2000, 10),
    (225, 2, 'misdemeanor', 'Accessory to Street Racing', 'Assisting or enabling unlawful racing.', 1000, 5),
    (226, 2, 'misdemeanor', 'Providing False Information', 'Giving false or misleading information to law enforcement.', 500, 5),
    (227, 2, 'misdemeanor', 'Public Endangerment', 'Reckless behavior placing others at risk.', 1200, 5),
    (228, 2, 'misdemeanor', 'Trespassing', 'Entering or remaining on property without permission.', 300, 5),
    (229, 2, 'misdemeanor', 'Vandalism', 'Damaging or graffitiing property.', 700, 5),
    (230, 2, 'misdemeanor', 'Withholding Information', 'Refusing to share critical information in an investigation.', 400, 5),
    (231, 2, 'misdemeanor', 'Failure to Stop for Police Vehicle', 'Not pulling over when signaled by police.', 800, 5),
    (232, 2, 'misdemeanor', 'Wasting Police Time', 'Misusing emergency or police resources.', 500, 5),
    (233, 2, 'misdemeanor', 'Perjury', 'Lying under oath.', 1500, 5),
    (234, 2, 'misdemeanor', 'Prostitution', 'Engaging in sexual acts for compensation.', 1000, 5),
    (235, 2, 'misdemeanor', 'Possession of Illegal Knife', 'Possessing outlawed or oversized bladed weapons.', 600, 5),
    (236, 2, 'misdemeanor', 'Hunting Without License', 'Hunting protected wildlife without proper permits.', 500, 5),
    (237, 2, 'misdemeanor', 'Illegal Trapping', 'Trapping wildlife in prohibited areas or methods.', 500, 5),
    (238, 2, 'misdemeanor', 'Minor Habitat Disturbance', 'Causing limited damage to wildlife habitats.', 400, 5),
    (239, 2, 'misdemeanor', 'Conspiracy (General)', 'Two or more persons conspiring to commit any crime other than serious felonies, or to falsely procure arrest, institute proceedings, cheat or defraud, prevent lawful trade, commit acts injurious to public health/morals/commerce/justice.', 1000, 5),
    (240, 2, 'misdemeanor', 'Harassment', 'Engaging in a course of conduct that alarms or seriously annoys another person and serves no legitimate purpose.', 500, 5),
    (241, 2, 'misdemeanor', 'Stalking', 'Willfully and maliciously engaging in a course of conduct that causes substantial emotional distress or fear of bodily harm.', 1000, 10),
    (242, 2, 'misdemeanor', 'Domestic Battery', 'Battery committed against a spouse, domestic partner, or family member.', 1000, 10);

-- ============================================
-- FELONIES - 300 SERIES
-- ============================================

INSERT IGNORE INTO `lbtablet_police_offences` (`id`, `category_id`, `class`, `title`, `description`, `fine`, `jail_time`) VALUES
    (301, 3, 'felony', 'Armed Robbery', 'Taking property by force while armed.', 5000, 30),
    (302, 3, 'felony', 'Accessory to Armed Robbery', 'Assisting an armed robbery.', 3000, 20),
    (303, 3, 'felony', 'Arson', 'Willfully setting fire to property.', 4000, 25),
    (304, 3, 'felony', 'Assault with Deadly Weapon', 'Assault using weapon capable of lethal force.', 4500, 30),
    (305, 3, 'felony', 'Accessory to ADW', 'Assisting ADW offense.', 3000, 25),
    (306, 3, 'felony', 'Assault on LEO', 'Assaulting peace officer performing duties.', 5000, 30),
    (307, 3, 'felony', 'Attempted Murder', 'Attempt to kill another.', 5000, 30),
    (308, 3, 'felony', 'Accessory to Attempted Murder', 'Assisting attempted murder.', 4000, 25),
    (309, 3, 'felony', 'Attempted Murder of LEO', 'Attempt to kill law enforcement officer.', 6000, 35),
    (310, 3, 'felony', 'Accessory to Attempted LEO Murder', 'Assisting attempted LEO murder.', 5000, 30),
    (311, 3, 'felony', 'Corruption of Government Position', 'Using public office for unlawful gain.', 3500, 25),
    (312, 3, 'felony', 'Dissuading a Witness', 'Preventing person from reporting or testifying.', 3500, 25),
    (313, 3, 'felony', 'Distribution of Illegal Firearms', 'Supplying unlawful weapons.', 5000, 30),
    (314, 3, 'felony', 'Extortion', 'Obtaining property through threats.', 4000, 30),
    (315, 3, 'felony', 'Escape', 'Unlawfully fleeing lawful custody.', 3500, 30),
    (316, 3, 'felony', 'Accessory to Escape', 'Assisting escape from custody.', 3000, 25),
    (317, 3, 'felony', 'Felony Drug Possession Class C', 'Higher-quantity possession.', 2000, 15),
    (318, 3, 'felony', 'Felony Drug Possession Class B', 'Higher-quantity possession.', 3000, 20),
    (319, 3, 'felony', 'Felony Drug Possession Class A', 'Highest-quantity possession.', 4000, 25),
    (320, 3, 'felony', 'Fleeing & Eluding (Felony)', 'Evading police with danger to public.', 4000, 30),
    (321, 3, 'felony', 'Hit & Run (With Injury)', 'Leaving scene of accident with injury/damage.', 3000, 25),
    (322, 3, 'felony', 'Grand Theft Auto', 'Stealing a motor vehicle.', 4000, 25),
    (323, 3, 'felony', 'Police Impersonation', 'Wearing law enforcement clothing or driving law enforcement vehicle to impersonate an officer.', 3500, 25),
    (324, 3, 'felony', 'Misuse of CAD/MDT System', 'Unauthorized access, misuse, or dissemination of police CAD/MDT information.', 3500, 25),
    (325, 3, 'felony', 'Poaching Protected Species', 'Killing or capturing protected wildlife in a prohibited manner.', 2500, 15),
    (326, 3, 'felony', 'Illegal Commercial Sale of Wildlife', 'Selling, trading, or transporting protected species for profit.', 3000, 20),
    (327, 3, 'felony', 'Habitat Destruction', 'Significant damage to wildlife habitats resulting in species harm.', 2500, 15),
    (328, 3, 'felony', 'Felony Theft', 'Stealing property valued above misdemeanor threshold.', 3500, 25),
    (329, 3, 'felony', 'Felony Vandalism', 'Property destruction exceeding misdemeanor limits or causing major financial loss.', 3000, 25),
    (330, 3, 'felony', 'Felony Bribery', 'Attempting to influence government or law enforcement with large-scale payments or schemes.', 5000, 30),
    (331, 3, 'felony', 'Conspiracy to Commit Serious Crime', 'Two or more persons conspiring to commit murder, robbery, sexual assault, kidnapping, arson, involuntary servitude, trafficking in persons, sex trafficking, or racketeering violations.', 5000, 30),
    (332, 3, 'felony', 'Kidnapping Second Degree', 'Willfully seizing, taking, or kidnapping another person with intent to keep the person secretly imprisoned, or to convey the person out of the jurisdiction, or detained against the person\'s will.', 4000, 25),
    (333, 3, 'felony', 'Kidnapping First Degree', 'Kidnapping a person with intent to hold for ransom, reward, to commit sexual assault, extortion, or robbery; or to kill or inflict substantial bodily harm; or to exact money from relatives/friends.', 6000, 35),
    (334, 3, 'felony', 'Accessory to Kidnapping', 'Aiding or abetting kidnapping in the first or second degree.', 4000, 25),
    (335, 3, 'felony', 'Murder First Degree', 'Willful, deliberate, and premeditated killing, or killing in the perpetration of kidnapping, sexual assault, robbery, burglary, invasion of the home, or arson.', 10000, 40),
    (336, 3, 'felony', 'Murder Second Degree', 'All other kinds of willful, deliberate, and premeditated killings not enumerated in first degree murder.', 8000, 35),
    (337, 3, 'felony', 'Manslaughter', 'Unlawful killing of a human being without malice, either voluntary upon a sudden quarrel or heat of passion, or involuntary in the commission of an unlawful act.', 5000, 25),
    (338, 3, 'felony', 'Sexual Assault', 'Subjecting another person to sexual penetration against the victim\'s will or under conditions in which the perpetrator knows the victim is incapable of resisting or understanding the nature of the conduct.', 6000, 35),
    (339, 3, 'felony', 'Robbery', 'Unlawful taking of personal property from another by means of force or violence or fear of injury, without the use of a deadly weapon.', 4000, 25),
    (340, 3, 'felony', 'Burglary', 'Entering any building, vehicle, or structure with the intent to commit larceny, assault, battery, or any felony.', 3500, 25),
    (341, 3, 'felony', 'Drug Trafficking Class C', 'Trafficking in low-level quantities of controlled substances.', 3000, 20),
    (342, 3, 'felony', 'Drug Trafficking Class B', 'Trafficking in moderate quantities of controlled substances.', 4000, 25),
    (343, 3, 'felony', 'Drug Trafficking Class A', 'Trafficking in high quantities of controlled substances.', 5000, 30),
    (344, 3, 'felony', 'Possession of Firearm by Prohibited Person', 'Possession of a firearm by a person prohibited due to prior felony conviction or other disqualifying factor.', 3000, 20),
    (345, 3, 'felony', 'Forgery', 'Falsely making, altering, or forging any document with intent to defraud.', 3500, 25),
    (346, 3, 'felony', 'Identity Theft', 'Willfully using identifying information of another person to avoid prosecution, obtain credit, or for other fraudulent purposes.', 4000, 25);

-- ============================================
-- WILDLIFE MISDEMEANORS - 400 SERIES
-- ============================================

INSERT IGNORE INTO `lbtablet_police_offences` (`id`, `category_id`, `class`, `title`, `description`, `fine`, `jail_time`) VALUES
    (401, 4, 'misdemeanor', 'Hunting Without License', 'Hunting protected wildlife without proper permits.', 500, 5),
    (402, 4, 'misdemeanor', 'Illegal Trapping', 'Trapping wildlife in prohibited areas or with banned methods.', 500, 5),
    (403, 4, 'misdemeanor', 'Minor Habitat Disturbance', 'Causing limited damage to wildlife habitats.', 400, 5),
    (404, 4, 'misdemeanor', 'Possession of Wildlife without Permit', 'Having animals or parts of animals that require a license or permit.', 500, 5),
    (405, 4, 'misdemeanor', 'Fishing Without License', 'Catching fish without a valid fishing license.', 400, 5),
    (406, 4, 'misdemeanor', 'Trespassing in Wildlife Preserve', 'Entering protected wildlife areas without permission.', 300, 5),
    (407, 4, 'misdemeanor', 'Feeding Prohibited Wildlife', 'Feeding wildlife in ways that endanger them or humans.', 250, 5),
    (408, 4, 'misdemeanor', 'Possession of Illegal Hunting Equipment', 'Owning traps, snares, or weapons banned for wildlife use.', 400, 5),
    (409, 4, 'misdemeanor', 'Disturbing Nesting or Denning Sites', 'Interfering with breeding or sheltering areas of wildlife.', 400, 5),
    (410, 4, 'misdemeanor', 'Minor Wildlife Theft', 'Taking wildlife or eggs without causing serious harm.', 500, 5);

-- ============================================
-- WILDLIFE FELONIES - 450 SERIES
-- ============================================

INSERT IGNORE INTO `lbtablet_police_offences` (`id`, `category_id`, `class`, `title`, `description`, `fine`, `jail_time`) VALUES
    (450, 5, 'felony', 'Poaching Protected Species', 'Killing or capturing protected wildlife in a prohibited manner.', 2500, 15),
    (451, 5, 'felony', 'Illegal Commercial Sale of Wildlife', 'Selling, trading, or transporting protected species for profit.', 3000, 20),
    (452, 5, 'felony', 'Habitat Destruction', 'Significant damage to wildlife habitats resulting in species harm.', 2500, 15),
    (453, 5, 'felony', 'Possession of Protected Wildlife for Commercial Use', 'Holding wildlife or products from protected species with intent to sell.', 3000, 20),
    (454, 5, 'felony', 'Hunting Endangered Species', 'Hunting species designated as endangered or critically endangered.', 3500, 20),
    (455, 5, 'felony', 'Large-Scale Illegal Capture', 'Capturing large numbers of protected wildlife or rare species.', 3000, 20),
    (456, 5, 'felony', 'Wildlife Smuggling', 'Transporting protected wildlife or parts across borders illegally.', 5000, 25),
    (457, 5, 'felony', 'Intentional Mass Habitat Destruction', 'Deliberate destruction of ecosystems causing widespread harm to wildlife.', 3500, 20),
    (458, 5, 'felony', 'Assault on Wildlife LEO', 'Assaulting or killing officers while enforcing wildlife laws.', 5000, 30),
    (459, 5, 'felony', 'Conspiracy / Organized Wildlife Crime', 'Participating in organized schemes targeting protected wildlife.', 5000, 30);
