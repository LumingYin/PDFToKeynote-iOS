//
//  MultpleLineLayout.m
//  
//
//  Created by Blue on 4/9/19.
//

#import "MultpleLineLayout.h"
#define space 10

@implementation MultpleLineLayout { // a subclass of UICollectionViewFlowLayout
    NSInteger itemWidth;
    NSInteger itemHeight;
}

-(id)init {
    if (self = [super init]) {
        itemWidth = 86;
        itemHeight = 86;
    }
    return self;
}

-(CGSize)collectionViewContentSize {
    NSInteger xSize = [self.collectionView numberOfItemsInSection:0] * (itemWidth + space); // "space" is for spacing between cells.
    NSInteger ySize = [self.collectionView numberOfSections] * (itemHeight + space);
    return CGSizeMake(xSize, ySize);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.size = CGSizeMake(itemWidth,itemHeight);
    long xValue = itemWidth/2 + path.row * (itemWidth + space);
    long yValue = itemHeight + path.section * (itemHeight + space);
    attributes.center = CGPointMake(xValue, yValue);
    return attributes;
}


-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger minRow =  (rect.origin.x > 0)?  rect.origin.x/(itemWidth + space) : 0; // need to check because bounce gives negative values  for x.
    NSInteger maxRow = rect.size.width/(itemWidth + space) + minRow;
    NSMutableArray* attributes = [NSMutableArray array];
    for(NSInteger i=0 ; i < self.collectionView.numberOfSections; i++) {
        for (NSInteger j=minRow ; j < maxRow; j++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return attributes;
}

@end
