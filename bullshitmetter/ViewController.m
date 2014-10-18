//
//  ViewController.m
//  bullshitmetter
//
//  Created by Thibaut LE LEVIER on 18/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () //<AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (strong, nonatomic) NSURL *fileURL;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileURL = [NSURL fileURLWithPathComponents:@[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"Bullshit.m4a"]];
    
    NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey: @(44100.0),
                                    AVNumberOfChannelsKey: @(2)};

    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.fileURL settings:recordSetting error:nil];
//    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

#pragma mark - action
-(IBAction)playStopAction:(id)sender
{
    if ([self.recorder isRecording])
    {
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        
        [self.recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
    else
    {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self.recorder record];
    }
}
@end
