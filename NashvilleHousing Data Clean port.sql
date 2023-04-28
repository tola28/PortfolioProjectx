
--Cleaning  Data in SQL Queries
*/

Select *
from PortfolioProject.dbo.NashvilleHousing

---Standardize Date Format (Sales date has time at the end, which is of no use). It is in date time format, so change to date format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update Portfolioproject.dbo.NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--You can elminate the first select and update as it is not needed. The alter table and second update is firstexecuted, then run the select dateconverted

--Populate Porperty Address data. We are doing this because if we have two parcel ID that are the same but different uniqueID, we want to populate or make the property address be the same specially if one of the property address is lacking (where property address is null) and the other has an address. We are joining together. 
Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--- Now that it is null, we want to populate the first property address (a.property address) to the second (b.proprty address), so the new role created will bw what we stick into the null values
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--To update. ISNULL, check to see if the first and scond is null and populate with a value
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Addressinto Individual columns (Address, City, State). A delimiter is something that seperates different columns or values (e.g comma). Charindex is to search for someting 
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


--We are using a substring and charindex, looking at property address from position 1, the chracter index will be searching for a specific value in property adress
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

--The result of the previous query guves us comma at the ened, which we want to remove,specifying charindex shows what position, the comma is in 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
 CHARINDEX(',', PropertyAddress)

From PortfolioProject.dbo.NashvilleHousing

-- So to remove the comma now that we know the position, we minus 1 value to remove the comma
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

From PortfolioProject.dbo.NashvilleHousing

--The next one, we are looking from the position of the comma (where the character index), not position 1. We have to start at +1 to go to the actual comma until the length of property address
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--We can't seperate two values to form one column without creating two other columns. So we are creating columns and adding the value in
ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

 -- Breaking out Address into Individual columns (Address, City, State) for owner address but using a simpler way instead of substring, caled a parse name. Parse name is useful for limites stuff delimited by a specific calue
 Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Nothing changes becaue PARSENAME is used for periods and these are commas. PARSENAME works backwards
Select
PARSENAME(OwnerAddress,1)
From PortfolioProject.dbo.NashvilleHousing

--To change it but it does this backwards
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
From PortfolioProject.dbo.NashvilleHousing

--To change it but it does this forward
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing


--Change Y and N to yes and No in "Sold as Vacant" field
--To see sold asvacant
Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing

--To see count arranged by ascending other of the 2 column
Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

--Then execute this, to see it works
Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--Remove Duplicates
--We don't normally need to delete dat from file but to do this: we write a cte and we do windows function to find where there are duplicate values
--We are writing the query first , then put in a CTE. We need a way to identify our duplicate rows, so we use things like rank, order rank, row number
--wWe need to see if there are duplicates in column like parcel id, property address but should be ordered by something unique. if we see row 1 and 2 in the row num, tehre are two duplicates

WITH RowNumCTE AS (
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
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num>1
Order by PropertyAddress
--This produces results of 104 dulicates

--Now to delete them
WITH RowNumCTE AS (
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
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE 
From RowNumCTE
where row_num>1
--Order by PropertyAddress

--Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate