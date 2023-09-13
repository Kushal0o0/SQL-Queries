SELECT * FROM nashville2.nashville;

----- standardize date format -----
SELECT SaleDate, CAST(SaleDate AS date) FROM nashville;
update nashville 
set SALEDATE = CAST(SaleDate AS date);

----- populate property address -----
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress from nashville a 
join nashville b 
on a.ParcelID = b.ParcelID and a.UID != b.uid
where a.PropertyAddress = "NA0";

UPDATE nashville a
JOIN nashville b ON a.ParcelID = b.ParcelID AND a.UID != b.UID
SET  a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = 'NA0';

----- splitting property address column -----
SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1) AS property_address, TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS property_city
FROM nashville;

-- add the new columns with separated values
ALTER TABLE nashville
ADD COLUMN property_address VARCHAR(255),
ADD COLUMN property_city VARCHAR(255);

-- Update the new columns and delete the original column
UPDATE nashville
SET
    property_address = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    property_city = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));
alter table nashville
 drop column PropertyAddress;

----- splitting owner address column -----
SELECT 
    TRIM(SUBSTRING_INDEX(owneraddress, ',', 1)) AS owner_address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -2), ',', 1)) AS owner_city,
    TRIM(SUBSTRING_INDEX(owneraddress, ',', -1)) AS owner_state
FROM nashville;

-- add the new columns with separated values
alter table nashville
add column owner_address varchar(255),
add column owner_city varchar(255),
add column owner_state varchar(255);

-- Update the new columns and delete the original column
update nashville 
set  owner_address = TRIM(SUBSTRING_INDEX(owneraddress, ',', 1)), 
	  owner_city = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -2), ',', 1)),
      owner_state =  TRIM(SUBSTRING_INDEX(owneraddress, ',', -1)) ;
alter table nashville
drop column  OwnerAddress;     

----- change Y and N to Yes and No in "Sold as Vacant" field -----
select SoldAsVacant,
case 
	when SoldAsVacant = "Y" then "Yes"
    when SoldAsVacant = "N" then "No"
    else SoldAsVacant
    end as sold_as_vacant
from nashville;

alter table nashville
add column sold_as_vacant varchar(255);

update nashville
set sold_as_vacant = case 
	when SoldAsVacant = "Y" then "Yes"
    when SoldAsVacant = "N" then "No"
    else SoldAsVacant
    end; 

alter table nashville
drop column SoldAsVacant;

----- Remove Duplicates -----
with row_num_CTE as 
(
select *, 
	row_number() over(partition by ParcelID, property_address, SalePrice, SaleDate, LegalReference order by UID) as "rownumber"
from nashville
order by ParcelID
)
delete from row_num_CTE
where rownumber > 1;




