Select * 
From portfolio.nashvillehousing;




-- Standardize Date Format

Select 
	SaleDate, 
    STR_TO_DATE(SaleDate,'%M %d,%Y') 
From portfolio.nashvillehousing;


Alter Table portfolio.nashvillehousing
Add SaleDateConverted Date;


Update portfolio.nashvillehousing
Set SaleDateConverted = STR_TO_DATE(SaleDate,'%M %d,%Y');


Select SaleDateConverted, STR_TO_DATE(SaleDate,'%M %d,%Y') 
From portfolio.nashvillehousing;







-- Populate 'null' property address data

Select *
From portfolio.nashvillehousing
Where PropertyAddress IS NULL
Order by ParcelID;



-- Analysis: Use a self join. If ParcelID is the same but UniqueID is different, then they should have the same address.

Select 
	a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    IFNULL(a.PropertyAddress, b.PropertyAddress) 
From portfolio.nashvillehousing a
Join portfolio.nashvillehousing b
	On a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress IS NULL;


Update portfolio.nashvillehousing a
Join portfolio.nashvillehousing b
	On a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Set a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
Where a.PropertyAddress IS NULL;








-- Breaking out address into individual columns (address, city, state)

Select PropertyAddress
From portfolio.nashvillehousing;


Select 
	Substring(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
	Substring(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as City
From portfolio.nashvillehousing;


Alter Table portfolio.nashvillehousing
Add PropertySplitAddress CHAR(255);
Update portfolio.nashvillehousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);


Alter Table portfolio.nashvillehousing
Add PropertySplitCity CHAR(255);
Update portfolio.nashvillehousing
Set PropertySplitCity = Substring(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));




-- Breaking out OwnerAddress into individual columns (address, city, state)

Select OwnerAddress
From portfolio.nashvillehousing;

Select
	Substring_Index(OwnerAddress,',', 1) as OwnerSplitAddress,
	Substring_Index(Substring_Index(OwnerAddress,',', 2), ',',-1) as OwnerSplitCity,
	Substring_Index(OwnerAddress,',', -1) as OwnerSplitState
From portfolio.nashvillehousing;


Alter Table portfolio.nashvillehousing
Add OwnerSplitAddress CHAR(255);
Update portfolio.nashvillehousing
Set OwnerSplitAddress = Substring_Index(OwnerAddress,',', 1);


Alter Table portfolio.nashvillehousing
Add OwnerSplitCity CHAR(255);
Update portfolio.nashvillehousing
Set OwnerSplitCity = Substring_Index(Substring_Index(OwnerAddress,',', 2), ',',-1);


Alter Table portfolio.nashvillehousing
Add OwnerSplitState CHAR(255);
Update portfolio.nashvillehousing
Set OwnerSplitState = Substring_Index(OwnerAddress,',', -1);







-- Change Y and N to Yes and No in "Sold as Vacant" field


Select 
	Distinct(SoldAsVacant), 
    Count(SoldAsVacant)
From portfolio.nashvillehousing
Group by SoldAsVacant
Order by 2;



Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' Then 'Yes'
    When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
End
From portfolio.nashvillehousing;

Select SoldAsVacant From portfolio.nashvillehousing
Where SoldAsVacant ='Y';



Update portfolio.nashvillehousing
Set SoldAsVacant = CASE
	When SoldAsVacant = 'Y' Then 'Yes'
    When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
End;








-- Remove Duplicates

Create Temporary Table RowNumCTE as
Select *,
	ROW_NUMBER() OVER(
    PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
    Order by UniqueID
    ) AS row_num
From portfolio.nashvillehousing;

Select * from RowNumCTE;

Delete From RowNumCTE
Where row_num >1;


Drop Temporary table RowNumCTE;








-- Delete Unused Columns
-- I recommend using a temporary table to delete columns instead of modifying the original raw data

Alter Table portfolio.nashvillehousing
Drop Column PropertyAddress,
Drop Column OwnerAddress, 
Drop Column TaxDistrict;

Alter Table portfolio.nashvillehousing
Drop Column SaleDate;
