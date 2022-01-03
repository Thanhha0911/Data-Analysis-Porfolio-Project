--- Change Data Type, Null Value/ Break down components in a column/ Correct inconsistent data/ Remove Duplicate


---- Change data type of SaleDate from Datetime to Date
ALTER TABLE P1..Nashville_Housing 
	ADD Sale_Date Date

UPDATE P1..Nashville_Housing
SET Sale_Date = Cast(SaleDate as date)

---- Delete SaleDate column
ALTER TABLE P1.. Nashville_Housing
	DROP COLUMN SaleDate


----- Check Null value in Property Address and find out why it has null value---------------------------------------------------------------------
SELECT  *
FROM P1..Nashville_Housing
WHERE PropertyAddress is null
----- We find out records that have null in Property Address is duplicate ParcelID with others
Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From P1..Nashville_Housing A
JOIN P1..Nashville_Housing B
	on A.ParcelID = B.ParcelID
	AND A.UniqueID  <> B.UniqueID
Where A.PropertyAddress is null



--- Split PropertyAdress column into Street and City----------------------------------------------------------------------------------------------


ALTER TABLE P1.. Nashville_Housing
 ADD Property_Street nvarchar(255), Property_City nvarchar(255)

UPDATE P1..Nashville_Housing
SET Property_Street = LEFT (PropertyAddress, CHARINDEX(',', PropertyAddress) -1 ),
	Property_City = RIGHT(PropertyAddress, LEN (PropertyAddress)- CHARINDEX(',', PropertyAddress) -1 )

	---- Delete PropertyAddress column
ALTER TABLE P1.. Nashville_Housing
	DROP COLUMN PropertyAddress

--- Split OwnerAddress column into Street, City, State---------------------------------------------------------------------------------------------

ALTER TABLE P1..Nashville_Housing
	ADD Owner_Street nvarchar(255), 
		Owner_City nvarchar(255),
		Owner_State nvarchar(255)

UPDATE P1..Nashville_Housing
SET Owner_Street = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress)-1),
	Owner_City =  LEFT(B, CHARINDEX(',', B)-1) 
					FROM (SELECT RIGHT(OwnerAddress, LEN(OwnerAddress)- CHARINDEX(',', OwnerAddress)-1) as B
								FROM P1..Nashville_Housing) AS A
UPDATE P1..Nashville_Housing
SET Owner_State = SUBSTRING(B,CHARINDEX(',', B)+2, LEN(B))
					FROM (SELECT RIGHT(OwnerAddress, LEN(OwnerAddress)- CHARINDEX(',', OwnerAddress)-1) as B
								FROM P1..Nashville_Housing) AS A

----- Delete OwnerAddress

ALTER TABLE P1.. Nashville_Housing
	DROP COLUMN OwnerAddress




---- Detect and correct inconsistent data in LandUse column---------------------------------------------------------------------------------------
SELECT 
	DISTINCT LandUse
FROM P1..Nashville_Housing
ORDER BY Landuse
----BOTH VACANT RESIDENTIAL LAND,VACANT RESIENTIAL LAND, VACANT RES LAND ARE THE SAME TYPE OF LANDUSE

ALTER TABLE P1..Nashville_Housing
	ADD Land_Use nvarchar(255)

UPDATE P1..Nashville_Housing
SET Land_Use = CASE WHEN LandUse in ('VACANT RESIENTIAL LAND', 'VACANT RES LAND') Then 'VACANT RESIDENTIAL LAND'
				ELSE Landuse END
				FROM P1..Nashville_Housing

ALTER TABLE P1..Nashville_Housing
	DROP COLUMN LandUse

------ Check SoldAsVacant Column
SELECT 
	DISTINCT SoldAsVacant
FROM P1..Nashville_Housing


---- Change Y and N into Yes and No in  SoldAsVacant

ALTER TABLE P1..Nashville_Housing
	ADD Sold_As_Vacant nvarchar(255)

UPDATE P1..Nashville_Housing
SET Sold_As_Vacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					ELSE SoldAsVacant END
					FROM P1..Nashville_Housing

ALTER TABLE P1..Nashville_Housing
	DROP COLUMN SoldAsVacant

------------------------------------------------------------------------------------------------------------------------------------------------------

----- (OwnerName, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath) have Null Value
----- Only change Null Value in (OwnerName,TaxDistrict) in to "Unknown"


UPDATE P1..Nashville_Housing
SET OwnerName = CASE WHEN OwnerName is Null THEN 'Unknown'
	ELSE OwnerName END
	FROM P1..Nashville_Housing

UPDATE P1..Nashville_Housing
SET TaxDistrict = CASE WHEN TaxDistrict is Null THEN 'Unknown'
	ELSE TaxDistrict END
	FROM P1..Nashville_Housing



---- REMOVE DUPLICATE -------------------------------------------------------------------------------------------------------------------------------

WITH A AS(
	SELECT *,
		ROW_NUMBER () OVER (PARTITION BY ParcelID, SalePrice, LegalReference, Sale_Date ORDER BY ParcelID) as Row_Col
	FROM P1..Nashville_Housing
)
SELECT *
FROM A
WHERE Row_col = 1
ORDER BY ParcelID