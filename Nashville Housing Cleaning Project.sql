-- Cleaning Housing Data in SQL

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardizing Date Format

select
SaleDateConverted, CONVERT(date, saledate)
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set saledate = CONVERT(date, saledate)

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(date, saledate)

-- Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select 
a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Break out Address into Individual Columns; Address, City, State

select
PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Same thing as above, but splitting Owner Address which include State data (NO SUBSTRINGS)

select
OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change 'Y' and 'N' to 'Yes' and 'No' in "Sold As Vacant" field

select
distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select
SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
			 When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
			 When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END

-- Remove Duplicates Using a CTE & Row Number

WITH RowNumCTE AS(
select *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
								 PropertyAddress,
								 SalePrice,
								 SaleDate,
								 LegalReference
								 ORDER BY
										UniqueID
										) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate