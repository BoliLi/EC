//
//  TableViewCellSlider.m
//  EasyCalc
//
//  Created by LiBoli on 16/6/10.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "TableViewCellSlider.h"

@implementation TableViewCellSlider
@synthesize slider;
@synthesize title;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)titleStr {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.title = [[UILabel alloc] init];
        
        if (titleStr != nil) {
            self.title.font = self.textLabel.font;
            self.title.text = titleStr;
            self.title.frame = CGRectMake(self.contentView.frame.size.width / 20.0, 10.0, self.contentView.frame.size.width, self.title.font.lineHeight);
            [self.contentView addSubview:self.title];
        }
        
        CGFloat x = self.contentView.frame.size.width / 20.0;
        CGFloat w = self.contentView.frame.size.width * 0.9;
        self.slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(x, self.title.frame.size.height + 30, w, self.textLabel.font.lineHeight)];
        self.slider.delegate = self;
        self.slider.continuous = YES;
        [self.contentView addSubview:self.slider];
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.slider.frame.origin.y + self.slider.frame.size.height + 10.0);
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)sliderWillDisplayPopUpView:(ASValueTrackingSlider *)slider;
{
    [self.superview bringSubviewToFront:self];
}


@end
