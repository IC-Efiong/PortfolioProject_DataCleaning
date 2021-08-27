/*

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data

---------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

SELECT SalesDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.Nashville_housing_data

UPDATE PortfolioProject..Nashville_housing_data
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject..Nashville_housing_data
ADD SalesDateConverted Date;

UPDATE PortfolioProject..Nashville_housing_data
SET SalesDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------

--Porpulate Proprty Address data

SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville_housing_data a
JOIN PortfolioProject.dbo.Nashville_housing_data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville_housing_data a
JOIN PortfolioProject.dbo.Nashville_housing_data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------
--Breaking Out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashville_housing_data
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.Nashville_housing_data

ALTER TABLE PortfolioProject..Nashville_housing_data
ADD PropertysplitAddress Nvarchar(255);

UPDATE PortfolioProject..Nashville_housing_data
SET PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..Nashville_housing_data
ADD PropertysplitCity Nvarchar(255);

UPDATE PortfolioProject..Nashville_housing_data
SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.Nashville_housing_data


--Owner Address
Select OwnerAddress
From PortfolioProject.dbo.Nashville_housing_data

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.Nashville_housing_data

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
Add OwnersplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville_housing_data
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
Add OwnersplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville_housing_data
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
Add OwnersplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville_housing_data
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


Select *
From PortfolioProject.dbo.Nashville_housing_data


--------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.Nashville_housing_data
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.Nashville_housing_data

Update PortfolioProject.dbo.Nashville_housing_data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH ROWNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.Nashville_housing_data
--order by ParcelID
)
Select *
From ROWNUMCTE
Where row_num >1
--Order by PropertyAddress

Select *
From PortfolioProject.dbo.Nashville_housing_data

-----------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

Select *
From PortfolioProject.dbo.Nashville_housing_data

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
DROP COLUMN SaleDate
