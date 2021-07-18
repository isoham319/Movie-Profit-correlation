-- Standardizing date format
update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

--PropertyAddress Null values filling
select PropertyAddress from NashvilleHousing
where PropertyAddress is null

select count(ParcelID),ParcelID,PropertyAddress from NashvilleHousing
Group by ParcelID, PropertyAddress
having count(ParcelID)>1 

-- Same number of PArcelID has 2 or 3 propertyAddress so nulls can be filled using ParcelID

select a.PropertyAddress,b.PropertyAddress,b.ParcelID,b.[UniqueID ], ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b 
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a 
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b 
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- seperating the address 


alter table nashvillehousing 
add PropertyHouseAddress nvarchar(255);

alter table nashvillehousing 
add PropertyCityAddress nvarchar(255);

update NashvilleHousing
set PropertyCityAddress =  
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) 
update NashvilleHousing
set PropertyHouseAddress =  
substring(propertyaddress,1,charindex(',',propertyaddress)-1) 

select * from NashvilleHousing

-- now same for ownerAddress but in a different way
--PARSENAME is more efficient because it just divides whole string divided by period(.)
select PARSENAME(replace(owneraddress,',','.'), 1),
PARSENAME(replace(owneraddress,',','.'), 2) ,
PARSENAME(replace(owneraddress,',','.'), 3) from NashvilleHousing


		alter table NashvilleHousing
		add OwnerHouseAddress NVarchar(255);

		alter table NashvilleHousing
		add OwnerCityAddress NVarchar(255);
		
		alter table NashvilleHousing
		add OwnerStateAddress NVarchar(255);

update NashvilleHousing
set OwnerHouseAddress = PARSENAME(replace(owneraddress,',','.'), 3)

update NashvilleHousing
set OwnerCityAddress = PARSENAME(replace(owneraddress,',','.'), 2)

update NashvilleHousing
set OwnerStateAddress = PARSENAME(replace(owneraddress,',','.'), 1)

select * from NashvilleHousing



--SoldAsVacant standardizing 
select distinct SoldAsVacant  from NashvilleHousing
-- we have different 2 value for yes and 2 values for no


update NashvilleHousing
set SoldAsVacant =
CASE 
when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end


-- Removing duplicates and unnecessary columns

with RowNumCTE AS(
select *, 
ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	Order by UniqueID
	) as RowNum
	from NashvilleHousing
)

--delete from RowNumCTE where RowNum>1
-- Uncomment delete one first 
Select * from RowNumCTE where RowNum>1


--Removing unwanted Columns 
alter table nashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

select * from NashvilleHousing