/*

CLEANING DATA IN SQL

*/

select *
from Nashvillehousing;

---Standardize Date Format

select SaleDate, convert(date, saledate)
from Nashvillehousing;

Update Nashvillehousing
set SaleDate = convert(date, saledate)

Alter table Nashvillehousing
Add saledateconverted date;

Update Nashvillehousing
set saledateconverted = convert(date, saledate)

select saledateconverted, convert(date, saledate)
from Nashvillehousing;

---Populate Property Address Date

select propertyaddress
from Nashvillehousing
where propertyaddress is null

select *
from Nashvillehousing
---where propertyaddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
Set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


--- Breaking out Address into Individual Column (Address, City, State)

select propertyaddress
from Nashvillehousing
--where propertyaddress is null
--order by parcelID

select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)) 
from Nashvillehousing

select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)) as Address,
charindex(',', PropertyAddress)
from Nashvillehousing

select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(propertyaddress, charindex(',', PropertyAddress) +1, LEN(propertyaddress)) as Address
from Nashvillehousing

Alter table Nashvillehousing
Add propertysplitaddress Nvarchar(255);

Update Nashvillehousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) -1)

Alter table Nashvillehousing
Add propertysplitcity Nvarchar(255);

Update Nashvillehousing
set propertysplitcity = SUBSTRING(propertyaddress, charindex(',', PropertyAddress) +1, LEN(propertyaddress)) 

select *
from Nashvillehousing


---Using an easier approach


select OwnerAddress
from Nashvillehousing

select
PARSENAME(Replace(owneraddress, ',', '.'), 3),
PARSENAME(Replace(owneraddress, ',', '.'), 2),
PARSENAME(Replace(owneraddress, ',', '.'), 1)
from Nashvillehousing

Alter table Nashvillehousing
Add ownersplitaddress Nvarchar(255);

Update Nashvillehousing
set ownersplitaddress = PARSENAME(Replace(owneraddress, ',', '.'), 3)

Alter table Nashvillehousing
Add ownersplitcity Nvarchar(255);

Update Nashvillehousing
set ownersplitcity = PARSENAME(Replace(owneraddress, ',', '.'), 2)

Alter table Nashvillehousing
Add ownersplitstate Nvarchar(255);

Update Nashvillehousing
set ownersplitstate = PARSENAME(Replace(owneraddress, ',', '.'), 1)

select *
from Nashvillehousing;

---Change Y and N to YES and NO in "Sold as Vacant" field

select distinct(soldasvacant)
from Nashvillehousing;

select distinct(soldasvacant), count(soldasvacant)
from Nashvillehousing
group by soldasvacant
order by 2;


select soldasvacant
, case	when soldasvacant = 'Y' then 'YES'
		when soldasvacant = 'N' then 'NO'
		else soldasvacant
		end
from Nashvillehousing;

update Nashvillehousing
set soldasvacant = case	when soldasvacant = 'Y' then 'YES'
		when soldasvacant = 'N' then 'NO'
		else soldasvacant
		end

select distinct(soldasvacant), count(soldasvacant)
from Nashvillehousing
group by soldasvacant
order by 2;

---Remove Deplicates

with row_numCTE as (
select *,
	Row_number() over (
	Partition by parcelID,
	Saleprice,
	Saledate,
	Legalreference
	order by
		uniqueID
		)Row_num

from Nashvillehousing
--order by ParcelID
)

select *
from row_numCTE
where row_num >1
order by PropertyAddress

with row_numCTE as (
select *,
	Row_number() over (
	Partition by parcelID,
	Saleprice,
	Saledate,
	Legalreference
	order by
		uniqueID
		)Row_num

from Nashvillehousing
--order by ParcelID
)

delete
from row_numCTE
where row_num >1
---order by PropertyAddress

Select *
from Nashvillehousing


----Delete Unused Column

Alter table Nashvillehousing
drop column Owneraddress, Taxdistrict, PropertyAddress

Alter table Nashvillehousing
drop column saledate