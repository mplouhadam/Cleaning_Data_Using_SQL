/*
Cleaning Data in SQL Queries
*/

-- Observe the data
SELECT *
FROM `practice-project-323312.Nashville_House.nashvillehouse`;

-- Convert string data type to date format
SELECT SaleDate, PARSE_DATE('%B %d, %Y', SaleDate) as dateformat
FROM `practice-project-323312.Nashville_House.nashvillehouse`;

ALTER TABLE `practice-project-323312.Nashville_House.nashvillehouse`
ADD COLUMN DateFormat Date;

UPDATE `practice-project-323312.Nashville_House.nashvillehouse`
SET DateFormat = PARSE_DATE('%B %d, %Y', SaleDate);


-- Populate PropertyAddress data
SELECT *
FROM `practice-project-323312.Nashville_House.nashvillehouse`
WHERE PropertyAddress IS NULL OR PropertyAddress = ''
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `practice-project-323312.Nashville_House.nashvillehouse` AS a
JOIN `practice-project-323312.Nashville_House.nashvillehouse` AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID_ != b.UniqueID_
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';

UPDATE a
SET PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `practice-project-323312.Nashville_House.nashvillehouse` a
JOIN `practice-project-323312.Nashville_House.nashvillehouse` b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL OR a.PropertyAddress = '';

-- Breaking out PropertyAddress into Individual Columns (Address and City)
SELECT PropertyAddress
FROM `practice-project-323312.Nashville_House.nashvillehouse`;

SELECT PropertyAddress,
REGEXP_EXTRACT(PropertyAddress, '[^,]*') as Address,
SUBSTR(PropertyAddress, (STRPOS(PropertyAddress, ',') + 1), (LENGTH(PropertyAddress) - STRPOS(PropertyAddress, ','))) as City,
FROM `practice-project-323312.Nashville_House.nashvillehouse`;

ALTER TABLE `practice-project-323312.Nashville_House.nashvillehouse`
ADD COLUMN Address STRING;

UPDATE `practice-project-323312.Nashville_House.nashvillehouse`
SET Address = REGEXP_EXTRACT(PropertyAddress, '[^,]*');

ALTER TABLE `practice-project-323312.Nashville_House.nashvillehouse`
ADD COLUMN City STRING;

Update `practice-project-323312.Nashville_House.nashvillehouse`
SET City = SUBSTR(PropertyAddress, (STRPOS(PropertyAddress, ',') + 1), (LENGTH(PropertyAddress) - STRPOS(PropertyAddress, ',')));

SELECT *
FROM `practice-project-323312.Nashville_House.nashvillehouse`;


-- Change true and false to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `practice-project-323312.Nashville_House.nashvillehouse`
GROUP BY SoldAsVacant
ORDER BY 2;

WITH newformat AS
(SELECT CAST(SoldAsVacant AS STRING) AS SoldAsVacant
FROM `practice-project-323312.Nashville_House.nashvillehouse`)
SELECT SoldAsVacant,
(CASE WHEN SoldAsVacant = 'true' THEN 'Yes'
     WHEN SoldAsVacant = 'false' THEN 'No'
	 END) AS NewSoldAsVacant
FROM newformat;

UPDATE `practice-project-323312.Nashville_House.nashvillehouse`
SET SoldAsVacant = CAST(SoldAsVacant AS STRING);
UPDATE `practice-project-323312.Nashville_House.nashvillehouse`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'true' THEN 'Yes'
	   WHEN SoldAsVacant = 'false' THEN 'No'
	   END;


-- Remove Duplicates
WITH RowNumb AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID_
					) AS row_num
FROM `practice-project-323312.Nashville_House.nashvillehouse`
)
SELECT *
FROM RowNumb
WHERE row_num > 1
ORDER BY PropertyAddress; #There is 103 rows duplicates
-- Let's remove
DELETE
FROM `practice-project-323312.Nashville_House.nashvillehouse` AS a
WHERE 
(SELECT ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID_
					) AS row_num
FROM `practice-project-323312.Nashville_House.nashvillehouse` AS b
WHERE a.UniqueID_ = b.UniqueID_
) > 1;


-- Delete Unused Columns
ALTER TABLE `practice-project-323312.Nashville_House.nashvillehouse`
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;