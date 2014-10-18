//
//  ViewController.m
//  bullshitmetter
//
//  Created by Thibaut LE LEVIER on 18/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController () //<AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (strong, nonatomic) NSURL *fileURL;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *startStopButton;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int currentTime;

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
    self.timeLabel.text = [NSString stringWithFormat:@"%i s",self.currentTime];
    
    
    if (self.currentTime == 0)
    {
        [self stopRecording];
    }
    
    self.currentTime--;
}

-(void)stopRecording
{
    self.timeLabel.text = @"ended";
    [self.timer invalidate];
    
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [self showHUD];
    
    NSData *file = [NSData dataWithContentsOfURL:self.fileURL];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://92.222.1.55"]];
    
    AFHTTPRequestOperation *op = [manager POST:@"/sound"
                                    parameters:nil
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                         [formData appendPartWithFileData:file
                                                     name:@"Bullshit"
                                                 fileName:@"Bullshit.m4a"
                                                 mimeType:@"audio/m4a"];
                         
                                        }
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           [self hideHUD];

                                           
                                        }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [self hideHUDWithCompletionMessage:error.localizedDescription];
                                        }];
    
    [op start];
}

-(void)processServerResponse:(NSDictionary *)serverResponse
{
    /*
     expecting
     
     {
     "buzzwords": [
     "foo",
     "bar"
     ],
     "grade": 12,
     "flesch-kincaid": 11.456,
     "recognized_text": "blabla blabla"
     }
     
     */
    
    serverResponse = @{ @"buzzwords" : @[@"foo", @"bar"],
                        @"grade" : @12,
                        @"flasch-kincaid" : @11.456 ,
                        @"recognized_text": @"Mister foo walk into a Bar"};
}

@end
