//
//  ViewController.m
//  bullshitmetter
//
//  Created by Thibaut LE LEVIER on 18/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WMGaugeView.h"

@interface ViewController () //<AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (strong, nonatomic) NSURL *fileURL;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *startStopButton;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int currentTime;

@property (weak, nonatomic) IBOutlet WMGaugeView *gaugeView;
@end

#define DURATION 30

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%i s",DURATION];
    
    self.fileURL = [NSURL fileURLWithPathComponents:@[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"Bullshit.m4a"]];
    
    NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey: @(44100.0),
                                    AVNumberOfChannelsKey: @(2)};

    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.fileURL settings:recordSetting error:nil];
//    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
    [self configureGaugeView];
}

#pragma mark - action
-(IBAction)playStopAction:(id)sender
{
    if ([self.recorder isRecording])
    {
        [self stopRecording];
    }
    else
    {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        
        self.currentTime = DURATION;

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(ticAction:)
                                                    userInfo:nil
                                                     repeats:YES];

        [self.timer fire];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self.recorder record];
    }
}

-(void)ticAction:(NSTimer *)timer
{
    [self.startStopButton setTitle:[NSString stringWithFormat:@"%i",self.currentTime] forState:UIControlStateNormal];
    
    
    if (self.currentTime == 0)
    {
        [self stopRecording];
    }
    
    self.currentTime--;
}

-(void)stopRecording
{
    self.timeLabel.text = @"ended";
    
    [self.startStopButton setTitle:@"Ended" forState:UIControlStateNormal];

    [self.timer invalidate];
    
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

-(void)configureGaugeView
{
    
}

@end
