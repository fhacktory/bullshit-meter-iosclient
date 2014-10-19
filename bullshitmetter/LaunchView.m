//
//  LaunchView.m
//  bullshitmetter
//
//  Created by Ludovic Ollagnier on 19/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "LaunchView.h"

@interface LaunchView ()
@property (weak, nonatomic) IBOutlet UIImageView *forbiddenSignImage;
@property (weak, nonatomic) IBOutlet UIImageView *bullImage;
@property (nonatomic) NSInteger currentTime;
@end

@implementation LaunchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:nil userInfo:nil repeats:YES];
        
        [timer fire];
        
    }
    return self;
}

- (void)showForbidden {
    
    self.currentTime++;
    
    if (self.currentTime == 2) {
        
        self.forbiddenSignImage.hidden = NO;
        
    }
    
}

@end
