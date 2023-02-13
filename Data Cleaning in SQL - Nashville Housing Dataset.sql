	--Cleaning the Nashville Housing Dataset--

	
	Select *
	FROM PortfolioProject.dbo.NashvilleHousing

	--1) Standardizing the date format--
	 Select SaleDate, CONVERT(date,SaleDate)
	FROM PortfolioProject.dbo.NashvilleHousing


	ALTER Table NashvilleHousing
	ADD SaleDateConverted DATE;

	Update NashvilleHousing
	SET SaleDateConverted=CONVERT(Date,SaleDate)

	Select SaleDateConverted
	FROM PortfolioProject.dbo.NashvilleHousing

	--2) Populating Property Address Data--
	SELECT PropertyAddress 
	FROM PortfolioProject.dbo.NashvilleHousing

	SELECT *
	FROM PortfolioProject.dbo.NashvilleHousing
	--WHERE PropertyAddress is null--
	ORDER BY ParcelID

	--Many Parcel IDs are repeated and they have the same Property address--
	--The populated addresses can be used to fill the missing ones based on the parcel id--

	--Self Joining Table--
	SELECT a.parcelid, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]  --parcel id is same, but it is not the same row which has to be joined--
	WHERE a.PropertyAddress is NULL

	Update a
	SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
	From PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is NULL

	--3) Breaking down Address into different columns (Address, City)
	SELECT PropertyAddress
	FROM PortfolioProject.dbo.NashvilleHousing

	SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
	From PortfolioProject.dbo.NashvilleHousing

	ALTER Table NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255) ;

	Update NashvilleHousing
	SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

	ALTER Table NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

	Update NashvilleHousing
	SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

	SELECT *
	FROM NashvilleHousing

	--4) Changing Y and N to Yes and No in 'Solid as Vacant' field--
	SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
	FROM NashvilleHousing
	Group By SoldAsVacant
	Order by 2

	Select SoldAsVacant
	, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
	From PortfolioProject.dbo.NashvilleHousing


	Update NashvilleHousing
	SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	--5)Removing Duplicates--
	--Using CTE and Windows functions--
	WITH RowNumCTE AS(
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
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing





	--6) Deleting unused columns--

	Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

