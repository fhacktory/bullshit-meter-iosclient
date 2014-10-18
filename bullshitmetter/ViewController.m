//
//  ViewController.m
//  bullshitmetter
//
//  Created by Thibaut LE LEVIER on 18/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - action
-(IBAction)playStopAction:(id)sender
{
    if ([self.recorder isRecording])
    {
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        [self.recorder stop];
    }
    else
    {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self.recorder record];
    }
}
@end
