//
//  DisplayView.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "DisplayView.h"

@implementation DisplayView
@synthesize cursor;
@synthesize inpOrg;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.cursor = [coder decodeObjectForKey:@"cursor"];
        self.inpOrg = [coder decodeCGPointForKey:@"inpOrg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.cursor forKey:@"cursor"];
    [coder encodeCGPoint:self.inpOrg forKey:@"inpOrg"];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
