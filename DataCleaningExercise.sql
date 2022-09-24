SELECT * 
FROM Jonabase.dbo.[dbo.NashvilleHousing$];

--convert date formating
SELECT SaleDate, convert(date,SaleDate)
FROM jonabase.dbo.[dbo.NashvilleHousing$];

UPDATE [dbo.NashvilleHousing$]
SET SaleDate = convert(date,SaleDate);

--Populate Property Address Data..populate missing propertyaddress with ones that do have it filled out.
SELECT a.ParcelID, ISNULL(a.PropertyAddress,B.PropertyAddress), b.ParcelID, b.PropertyAddress
FROM Jonabase.dbo.[dbo.NashvilleHousing$] a
JOIN Jonabase.dbo.[dbo.NashvilleHousing$] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Jonabase.dbo.[dbo.NashvilleHousing$] a
JOIN Jonabase.dbo.[dbo.NashvilleHousing$] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out address into individual columns (address, city, state)
SELECT PropertyAddress
FROM jonabase.dbo.[dbo.NashvilleHousing$]

SELECT SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)) as StreetAddress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as CityAddress
FROM Jonabase.dbo.[dbo.NashvilleHousing$];

ALTER TABLE jonabase.dbo.[dbo.NashvilleHousing$]
	ADD StreetAddress Nvarchar(255),
		CityAddress Nvarchar(255);

UPDATE jonabase.dbo.[dbo.NashvilleHousing$]
SET StreetAddress = SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)),
	CityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

-- Breaking out Address again but with Parsename 
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3), PARSENAME(REPLACE(OwnerAddress,',','.'),2),PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Jonabase.dbo.[dbo.NashvilleHousing$];

ALTER TABLE jonabase.dbo.[dbo.NashvilleHousing$]
	ADD OwnerStreet Nvarchar(255), OwnerCity Nvarchar(255), OwnerState Nvarchar(255)

UPDATE jonabase.dbo.[dbo.NashvilleHousing$]
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-- SoldasVacant  Y/N -> Yes / No
SELECT SoldasVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant END
FROM jonabase.dbo.[dbo.NashvilleHousing$]

UPDATE jonabase.dbo.[dbo.NashvilleHousing$]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant END;

-- Remove Duplicates (Typically not standard practice to delete data from database)
-- if parcel number has a dupe, etc. then remove
WITH rownumcte as (SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, SalePrice, LegalReference
	ORDER BY ParcelID) row_num
FROM jonabase.dbo.[dbo.NashvilleHousing$])
	SELECT * --DELETE 
	FROM rownumcte
	WHERE row_num > 1	

-- Delete Unused Columns
SELECT *
FROM jonabase.dbo.[dbo.NashvilleHousing$]

ALTER TABLE jonabase.dbo.[dbo.NashvilleHousing$]
	DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate