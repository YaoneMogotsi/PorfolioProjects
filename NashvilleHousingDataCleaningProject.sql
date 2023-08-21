/*
	Cleaning data is SQL with Querries
*/

Select *
From PortfolioProjects..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDate, CONVERT(date, SaleDate) as StandardDate
From PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
Add SalesDateConverted Date;

UPDATE NashvilleHousing
Set SalesDateConverted = CONVERT(date,SaleDate)

Select SalesDateConverted
From PortfolioProjects..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data
-- Any Null fields in PropertyAddress field get populated using the ParcelID tables

Select PropertyAddress
From PortfolioProjects..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddressFiller
From PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is not null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)
-- Separating using the , delimiter

Select PropertyAddress 
From PortfolioProjects..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProjects..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select PropertySplitAddress
From PortfolioProjects..NashvilleHousing

Select PropertySplitCity
From PortfolioProjects..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking up owner address
-- Separating using the ','delimiter

Select OwnerAddress
From PortfolioProjects..NashvilleHousing

-- Separates using the '.', therefore in order to use PARSENAME, must change the ','to '.'instead using REPLACE
-- PARSENAME separates from back to front, so when writing, 3,2,1

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
From PortfolioProjects..NashvilleHousing


Alter Table PortfolioProjects..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProjects..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update PortfolioProjects..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update PortfolioProjects..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)


-- Checking updates

Select *
From PortfolioProjects..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO is "Sold as Vacant"field

-- Count

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates

-- Show Duplicates

With RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) as row_num
From PortfolioProjects..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress 

-- Deleting Duplicates
With RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) as row_num
From PortfolioProjects..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1


-- Check updates

With RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) as row_num
From PortfolioProjects..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress 

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing un-used columns only from views nd not raw_data

Select *
From PortfolioProjects..NashvilleHousing

Alter Table PortfolioProjects..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--------------------------------------------------------------------------------------------------------------------------------------------------------
