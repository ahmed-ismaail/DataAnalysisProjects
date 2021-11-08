
--see all data
select * from 
PortfolioProjectCovid..Housing
-------------------------------------------------------------------------------------------------

--convert datetime to date

alter table Housing
add SaleDateConverted date;

update Housing
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted from PortfolioProjectCovid..Housing
------------------------------------------------------------------------------------------------------------

--populate property address data	

select * 
from PortfolioProjectCovid..Housing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjectCovid..Housing a
join PortfolioProjectCovid..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjectCovid..Housing a
join PortfolioProjectCovid..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------

-- breaking out address to three columns (address, city, state)

select PropertyAddress from PortfolioProjectCovid..Housing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
from PortfolioProjectCovid..Housing;

alter table Housing
add PropertySplitAddress nvarchar(255);

update Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 );

alter table Housing
add PropertySplitCity nvarchar(255);

update Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

select * from PortfolioProjectCovid..Housing

-----------------------------------------

select OwnerAddress from PortfolioProjectCovid..Housing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as city,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as state
from PortfolioProjectCovid..Housing

alter table housing
add OwnerSplitAddress nvarchar(255);

update Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);


alter table housing
add OwnerSplitCity nvarchar(255);

update Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);


alter table housing
add OwnerSplitState nvarchar(255);

update Housing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

select * from PortfolioProjectCovid..Housing

------------------------------------------------------------------------------------------------------------

--replace Y and Y to Yes and No in SoldAsVacant column

select Distinct(SoldAsVacant), count(SoldAsVacant)
from Housing
group by SoldAsVacant

select SoldAsVacant ,case when SoldAsVacant = 'Y' then 'Yes' 
                   when SoldAsVacant = 'N' then 'No'
				   else SoldAsVacant end
from Housing

update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
                   when SoldAsVacant = 'N' then 'No'
				   else SoldAsVacant end;


select Distinct(SoldAsVacant), count(SoldAsVacant)
from Housing
group by SoldAsVacant

------------------------------------------------------------------------------------------------------------

--delete unused columns

select *
from Housing


alter table housing
drop column OwnerAddress, PropertyAddress, TaxDistrict;


alter table housing
drop column SaleDate;