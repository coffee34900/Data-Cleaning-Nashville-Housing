Select * from projectportfolio..Nashville_housing


--Standarazing sale data


Select  Saledateconverted,convert(date,saledate) as saledate_2
from projectportfolio..Nashville_housing

ALTER TABLE Nashville_housing
ADD Saledateconverted date 

UPDATE Nashville_housing
SET SaleDateconverted=CONVERT(date,saledate)


--Property adress data (Dealing with Nulls)


SELECT *
FROM projectportfolio..Nashville_housing
--where PropertyAddress is NULL
ORDER BY ParcelID


--Since most of them have a same parcel adress, we can use it to populate the Nulls.


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM projectportfolio..Nashville_housing a
JOIN projectportfolio..Nashville_housing b
ON a.ParcelID=b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM projectportfolio..Nashville_housing a
JOIN projectportfolio..Nashville_housing b
ON a.ParcelID=b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- Seprating property address into indvisual columns (Address,City,State) using substrings.


SELECT PropertyAddress
FROM projectportfolio..Nashville_housing

SELECT SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)+1) AS Address

FROM projectportfolio..Nashville_housing 

ALTER TABLE Nashville_housing
ADD PropertySplitAddress NVARCHAR(200); 

UPDATE Nashville_housing
SET PropertySplitAddress=SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE Nashville_housing
ADD PropertySplitCity NVARCHAR(200);

UPDATE Nashville_housing
SET PropertySplitCity=SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)+1)


--Similar procedure for OwnerAdress using PARSNAME


SELECT OwnerAddress
FROM projectportfolio..Nashville_housing 

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM projectportfolio..Nashville_housing

ALTER TABLE Nashville_housing
ADD OwnerSplitAddress NVARCHAR(200)

UPDATE Nashville_housing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashville_housing
ADD OwnerSplitCity NVARCHAR(200)

UPDATE Nashville_housing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_housing
ADD OwnerSplitState NVARCHAR(200)

UPDATE Nashville_housing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" column


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM projectportfolio..Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM projectportfolio..Nashville_housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates (USING CTE)


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) row_num
FROM projectportfolio..Nashville_housing
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM projectportfolio..Nashville_housing


-- Delete Unused Columns


SELECT *
FROM projectportfolio..Nashville_housing

ALTER TABLE projectportfolio..Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate