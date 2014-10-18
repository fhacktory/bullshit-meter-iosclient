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
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

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

#pragma mark - UI 

-(void)configureGaugeView
{
    [self.gaugeView setInnerBackgroundStyle:WMGaugeViewInnerBackgroundStyleGradient];
    self.gaugeView.showInnerBackground = NO;
    self.gaugeView.scaleStartAngle = 90;
    self.gaugeView.scaleEndAngle = 270;
    
    self.gaugeView.maxValue = 20.0;
    self.gaugeView.minValue = 0.0;
    self.gaugeView.value = 0;

    _gaugeView.showRangeLabels = YES;
    _gaugeView.rangeValues = @[ @5,                  @10,                @15,               @20              ];
    _gaugeView.rangeColors = @[ RGB(27, 202, 33), RGB(232, 231, 33),   RGB(232, 111, 33),   RGB(231, 32, 43)    ];
    _gaugeView.rangeLabels = @[ @"NUL",          @"FAIBLE",             @"OK",              @"BULLSHIT"        ];
    _gaugeView.unitOfMeasurement = @"Bullshit-O-mètre";
    _gaugeView.unitOfMeasurementColor = [UIColor blackColor];
    _gaugeView.showUnitOfMeasurement = YES;
    _gaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    _gaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    
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
        [session setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        
        BOOL ok = [self.recorder record];
        NSLog(@"%d", ok);
        
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
    
    _gaugeView.value = rand()%(int)_gaugeView.maxValue;

}

#pragma mark - processing sound and server result

-(void)stopRecording
{
    self.timeLabel.text = @"ended";
    
    [self.startStopButton setTitle:@"Ended" forState:UIControlStateNormal];

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
                        @"recognized_text": @"Mister Foo walk into a Bar named The Foo"};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:serverResponse[@"recognized_text"]];
    
    NSArray *words = serverResponse[@"buzzwords"];
    
    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange searchRange = NSMakeRange(0, [string.string length]);
        
        NSRange range;
        while ((range = [string.string rangeOfString:obj options:NSCaseInsensitiveSearch range:searchRange]).location != NSNotFound) {
            
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.textView.font.pointSize] range:range];
            
            searchRange = NSMakeRange(NSMaxRange(range), [string.string length] - NSMaxRange(range));
        }
    }];
    
    self.textView.attributedText = string;
    [self.gaugeView setValue:[serverResponse[@"grade"] floatValue] animated:YES];
    
}

@end
