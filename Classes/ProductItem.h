//
//  ProductItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DistributionCenter.h"
#import "Store.h"

static NSString * const ITEM_STATUS_NON_STOCK = @"N";
static NSString * const ITEM_STATUS_FREIGHT = @"F";

typedef enum { 
    UOMPrimary = 0,
    UOMSecondary = 1 
} SelectedUOM;

@interface ProductItem : NSObject {
    NSNumber *itemId;
    
    // Basic Info
    NSString *sku;
    NSString *description;
    NSString *vendorName;
    NSString *statusCode;
    NSString *type;
    NSNumber *typeId;
    
    NSString *openItemStatus;
    
    // Stocking Information
    NSString *binLocation;
    NSString *stockingCode;
    
    // Unit of Measure Info
    SelectedUOM selectedUOM;
    
    BOOL defaultToBox;
    NSNumber *piecesPerBox;
    NSString *primaryUnitOfMeasure;
    NSString *secondaryUnitOfMeasure;
    NSDecimalNumber *conversion;
    
    // Pricing Info
    NSNumber *priceGroupId;
    NSDecimalNumber *retailPricePrimary;
    NSDecimalNumber *retailPriceSecondary;
    NSDecimalNumber *standardCost;
    NSDecimalNumber *taxRate;
    BOOL taxExempt; 

    
    // Store
    Store *store;
    
    // Distribution Center Info
    NSArray *distributionCenterList;
	
	NSDictionary *unitOfMeasureLookup;
    
    //Enning Tang ShipToStoreID
    NSString *ShipToStoreID;
    
    //Enning Tang Added LTL Weight 2013/02/06
    NSNumber *itemLTLWeight;
    
    //Enning Tang Added SellingPrice
    NSDecimalNumber *sellingPricePrimary;
    NSDecimalNumber *sellingPriceSecondary;
    
}

extern NSString * const UOM_EACH;
extern NSString * const UOM_CARTON;
extern NSString * const UOM_BOX;
extern NSString * const UOM_COVERAGE;
extern NSString * const UOM_LINEARFOOT;
extern NSString * const UOM_QYARD;
extern NSString * const UOM_SET;
extern NSString * const UOM_SQFT;

@property(nonatomic, retain) NSNumber *itemId;
@property(nonatomic, retain) NSNumber *itemQty;
@property(nonatomic, retain) NSString *sku;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *vendorName;
@property(nonatomic, retain) NSString *statusCode;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSNumber *typeId;
@property(nonatomic, retain) NSString *binLocation;
@property(nonatomic, retain) NSString *stockingCode;

@property (nonatomic, assign) SelectedUOM selectedUOM;
@property                    BOOL defaultToBox;
@property(nonatomic, retain) NSNumber *piecesPerBox;
@property(nonatomic, retain) NSString *primaryUnitOfMeasure;
@property(nonatomic, retain) NSString *secondaryUnitOfMeasure;
@property(nonatomic, retain) NSDecimalNumber *conversion;
@property(nonatomic, retain) NSNumber *priceGroupId;
@property(nonatomic, retain) NSDecimalNumber *retailPricePrimary;
@property(nonatomic, retain) NSDecimalNumber *retailPriceSecondary;
@property(nonatomic, retain) NSDecimalNumber *standardCost;
@property(nonatomic, retain) NSDecimalNumber *taxRate;
@property                    BOOL taxExempt;

@property (nonatomic, retain) Store *store;
@property(nonatomic, retain) NSArray *distributionCenterList;

@property(nonatomic, retain) NSString *openItemStatus;

@property (nonatomic, retain) NSString *ShipToStoreID;

//Enning Tang Added itemLTLWeight 2013/02/06
@property(nonatomic, retain) NSNumber *itemLTLWeight;

//Enning Tang Added sellingPrice 8/23/2013
@property (nonatomic, retain) NSDecimalNumber *sellingPricePrimary;
@property (nonatomic, retain) NSDecimalNumber *sellingPriceSecondary;


- (BOOL) isUOMConversionRequired;
- (void) toggleUOM;
- (NSString *) getSelectedUOMForDisplay;

- (NSString *) getRetailPriceForDisplay;
-(NSString *) unitOfMeasureDisplay:(NSString*)uom;
- (NSComparisonResult)compare:(id)otherObject;

#pragma mark -
#pragma mark Marshalling methods
+ (ProductItem *) fromXml: (NSString *) xmlString;
+ (NSArray *) listFromXml: (NSString *) xmlString;
- (NSString *) toXml;

@end
