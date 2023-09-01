CREATE TABLE `trunk` (
	`vehiclePlate` VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`vehicleData` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb4_general_ci',
	`vehicleMoney` INT(11) NULL DEFAULT '0'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;