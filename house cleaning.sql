-- The purpose is to clean the data and make it more usables.

-- Just understanding the dataset
SELECT TOP (10) *
  FROM [cleaning project].[dbo].[NashvilleHousing]


  


  -- Standardize Date Format

  select SaleDate, convert(Date, SaleDate)
  FROM [cleaning project].[dbo].[NashvilleHousing]

  update [cleaning project].[dbo].NashvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate)

  alter table [cleaning project].[dbo].NashvilleHousing
  add SaleDateConverted Date;

  update [cleaning project].[dbo].NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

  select SaleDateConverted, convert(Date, SaleDate)
  FROM [cleaning project].[dbo].[NashvilleHousing]





  -- Populate Property Address Data


  select *
  from [cleaning project].[dbo].[NashvilleHousing]
  --where PropertyAddress  IS NULL
  order by ParcelID



  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
  from [cleaning project].[dbo].[NashvilleHousing] a
  join [cleaning project].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null


  update a
  set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from [cleaning project].[dbo].[NashvilleHousing] a
  join [cleaning project].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null







  --  Breaking Out Address into Individual Column ( Address, City, State)

  select PropertyAddress
  from [cleaning project].dbo.NashvilleHousing


  select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)  as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
  from [cleaning project].dbo.NashvilleHousing

  use [cleaning project]
  ALTER TABLE NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


  ALTER TABLE NashvilleHousing
  Add PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

  select *
  from [cleaning project].dbo.NashvilleHousing

  select OwnerAddress
  from [cleaning project].dbo.NashvilleHousing

  select 
  PARSENAME(Replace(OwnerAddress,',','.'), 3),
  PARSENAME(Replace(OwnerAddress,',','.'), 2),
  PARSENAME(Replace(OwnerAddress,',','.'), 1)
  from [cleaning project].dbo.NashvilleHousing

  use [cleaning project]
  ALTER TABLE NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)


  ALTER TABLE NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)


  ALTER TABLE NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

  select *
  from [cleaning project].dbo.NashvilleHousing


  ------------------

  -- Change Y and N to Yes and No in "Sold as Vacant" field


  Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
  from [cleaning project].dbo.NashvilleHousing
  group by SoldAsVacant
  order by 2




  select SoldAsVacant
  , case 
  when SoldAsVacant = 'Y' Then 'Yes'
  when SoldAsVacant = 'N' Then 'No'
  ELSE SoldAsVacant
  End 
  from [cleaning project].dbo.NashvilleHousing


  Update NashvilleHousing
  SET SoldAsVacant = case 
  when SoldAsVacant = 'Y' Then 'Yes'
  when SoldAsVacant = 'N' Then 'No'
  ELSE SoldAsVacant
  End


    

  ------------------

  -- Remove Duplicates 
  -- first checking the dupliucates and then removing accordingly

  -- checking
  with RowNumCTE as (
  select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
  from [cleaning project].dbo.NashvilleHousing
  )

  select *
  from RowNumCTE
  where row_num >1

  -- deleting the duplicates
  with RowNumCTE as (
  select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
  from [cleaning project].dbo.NashvilleHousing
  )


  DELETE
  from RowNumCTE
  where row_num >1



  ------------------------
  -- Delete Unused Columns 

  select *
  from [cleaning project].dbo.NashvilleHousing


  alter table [cleaning project].dbo.NashvilleHousing
  drop column OwnerAddress, TaxDistrict, PropertyAddress
  
  alter table [cleaning project].dbo.NashvilleHousing
  drop column SaleDate