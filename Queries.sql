SELECT *
FROM [MyDB].[dbo].[NashvilleHousing]

-- Standarize date format
ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD SaleDateConverted DATE

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate property address data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [MyDB].[dbo].[NashvilleHousing] AS A
JOIN [MyDB].[dbo].[NashvilleHousing] AS B
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Break out address into individual columns (address, city, state)
ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE [MyDB].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant field
UPDATE [MyDB].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					    END

-- Remove duplicates
WITH CTE AS (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID ) AS row_num
			FROM [MyDB].[dbo].[NashvilleHousing]
)
SELECT * 
FROM CTE
WHERE row_num > 1

-- Delete Unused Columns
ALTER TABLE [MyDB].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate