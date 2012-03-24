//
//  CSLinearLayoutView.m
//  CSLinearLayoutView
//
//  Created by Charles Scalesse on 3/24/12.
//  Copyright (c) 2012 Charles Scalesse. All rights reserved.
//

#import "CSLinearLayoutView.h"

@implementation CSLinearLayoutView

@synthesize items = _items;
@synthesize orientation = _orientation;


#pragma mark - Factories

- (id)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        self.autoresizesSubviews = NO;
        self.orientation = CSLinearLayoutViewOrientationVertical;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        self.autoresizesSubviews = NO;
        self.orientation = CSLinearLayoutViewOrientationVertical;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        self.autoresizesSubviews = NO;
        self.orientation = CSLinearLayoutViewOrientationVertical;
    }
    return self;
}


#pragma mark - Lifecycle

- (void)dealloc {
    [_items release], _items = nil;
    
    [super dealloc];
}


#pragma mark - Layout

- (void)layoutSubviews {

    CGFloat relativePosition = 0.0;
    CGFloat absolutePosition = 0.0;
    
    for (CSLinearLayoutItem *item in _items) {
        
        CGFloat startPadding = 0.0;
        CGFloat endPadding = 0.0;
        
        if (self.orientation == CSLinearLayoutViewOrientationHorizontal) {
            
            startPadding = item.padding.left;
            endPadding = item.padding.right;
            
            if (item.verticalAlignment == CSLinearLayoutItemVerticalAlignmentTop) {
                absolutePosition = item.padding.top;
            } else if (item.verticalAlignment == CSLinearLayoutItemVerticalAlignmentBottom) {
                absolutePosition = self.frame.size.height - item.view.frame.size.height - item.padding.bottom;
            } else { // CSLinearLayoutItemVerticalCenter
                absolutePosition = (self.frame.size.height / 2) - ((item.view.frame.size.height + (item.padding.bottom - item.padding.top)) / 2);
            }
            
        } else {
            
            startPadding = item.padding.top;
            endPadding = item.padding.bottom;
            
            if (item.horizontalAlignment == CSLinearLayoutItemHorizontalAlignmentLeft) {
                absolutePosition = item.padding.left;
            } else if (item.horizontalAlignment == CSLinearLayoutItemHorizontalAlignmentRight) {
                absolutePosition = self.frame.size.width - item.view.frame.size.width - item.padding.right;
            } else { // CSLinearLayoutItemHorizontalCenter
                absolutePosition = (self.frame.size.width / 2) - ((item.view.frame.size.width + (item.padding.right - item.padding.left)) / 2);
            }
            
        }
        
        relativePosition += startPadding;
        
        CGFloat delta = 0.0;
        if (self.orientation == CSLinearLayoutViewOrientationHorizontal) {
            item.view.frame = CGRectMake(relativePosition, absolutePosition, item.view.frame.size.width, item.view.frame.size.height);
            delta = item.view.frame.size.width;
        } else {
            item.view.frame = CGRectMake(absolutePosition, relativePosition, item.view.frame.size.width, item.view.frame.size.height);
            delta = item.view.frame.size.height;
        }
        
        relativePosition += delta + endPadding;
        
    }
    
}


#pragma mark - Overrides

- (void)setOrientation:(CSLinearLayoutViewOrientation)anOrientation {
    _orientation = anOrientation;
    [self setNeedsLayout];
}


#pragma mark - Add, Remove, Insert, & Move

- (void)addItem:(CSLinearLayoutItem *)linearLayoutItem {
    if (linearLayoutItem == nil || [_items containsObject:linearLayoutItem] == YES) {
        return;
    }
    
    [_items addObject:linearLayoutItem];
    [self addSubview:linearLayoutItem.view];
}

- (void)removeItem:(CSLinearLayoutItem *)linearLayoutItem {
    if (linearLayoutItem == nil || [_items containsObject:linearLayoutItem] == NO) {
        return;
    }
    
    [_items removeObject:linearLayoutItem];
    [linearLayoutItem.view removeFromSuperview];
}

- (void)insertItem:(CSLinearLayoutItem *)newItem beforeItem:(CSLinearLayoutItem *)existingItem {
    if (newItem == nil || [_items containsObject:newItem] == YES || existingItem == nil ||  [_items containsObject:existingItem] == NO) {
        return;
    }
    
    NSUInteger index = [_items indexOfObject:existingItem];
    [_items insertObject:newItem atIndex:index];
    [self addSubview:newItem.view];
}

- (void)insertItem:(CSLinearLayoutItem *)newItem afterItem:(CSLinearLayoutItem *)existingItem {
    if (newItem == nil || [_items containsObject:newItem] == YES || existingItem == nil || [_items containsObject:existingItem] == NO) {
        return;
    }
    
    if (existingItem == [_items lastObject]) {
        [_items addObject:newItem];
    } else {
        NSUInteger index = [_items indexOfObject:existingItem];
        [_items insertObject:newItem atIndex:++index];
    }
    
    [self addSubview:newItem.view];
}

- (void)insertItem:(CSLinearLayoutItem *)newItem atIndex:(NSUInteger)index {
    if (newItem == nil || [_items containsObject:newItem] == YES || index >= [_items count]) {
        return;
    }
    
    [_items insertObject:newItem atIndex:index];
    [self addSubview:newItem.view];
}

- (void)moveItem:(CSLinearLayoutItem *)movingItem beforeItem:(CSLinearLayoutItem *)existingItem {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || existingItem == nil || [_items containsObject:existingItem] == NO || movingItem == existingItem) {
        return;
    }
    
    NSUInteger existingItemIndex = [_items indexOfObject:existingItem];
    [_items removeObject:movingItem];
    [_items insertObject:movingItem atIndex:existingItemIndex];
    
    [self setNeedsLayout];
}

- (void)moveItem:(CSLinearLayoutItem *)movingItem afterItem:(CSLinearLayoutItem *)existingItem {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || existingItem == nil || [_items containsObject:existingItem] == NO || movingItem == existingItem) {
        return;
    }
    
    [_items removeObject:movingItem];
    
    if (existingItem == [_items lastObject]) {
        [_items addObject:movingItem];
    } else {
        NSUInteger existingItemIndex = [_items indexOfObject:existingItem];
        [_items insertObject:movingItem atIndex:++existingItemIndex];
    }
    
    [self setNeedsLayout];
}

- (void)moveItem:(CSLinearLayoutItem *)movingItem toIndex:(NSUInteger)index {
    if (movingItem == nil || [_items containsObject:movingItem] == NO || index >= [_items count] || [_items indexOfObject:movingItem] == index) {
        return;
    }
    
    [_items removeObject:movingItem];
    
    if (index == ([_items count] - 1)) {
        [_items addObject:movingItem];
    } else {
        [_items insertObject:movingItem atIndex:index];
    }
    
    [self setNeedsLayout];
}

- (void)swapItem:(CSLinearLayoutItem *)firstItem withItem:(CSLinearLayoutItem *)secondItem {
    if (firstItem == nil || [_items containsObject:firstItem] == NO || secondItem == nil || [_items containsObject:secondItem] == NO || firstItem == secondItem) {
        return;
    }
    
    NSUInteger firstItemIndex = [_items indexOfObject:firstItem];
    NSUInteger secondItemIndex = [_items indexOfObject:secondItem];
    [_items exchangeObjectAtIndex:firstItemIndex withObjectAtIndex:secondItemIndex];
    
    [self setNeedsLayout];
}

@end
