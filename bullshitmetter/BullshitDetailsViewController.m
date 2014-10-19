//
//  BullshitDetailsViewController.m
//  bullshitmetter
//
//  Created by Ludovic Ollagnier on 19/10/2014.
//  Copyright (c) 2014 Thibaut LE LEVIER. All rights reserved.
//

#import "BullshitDetailsViewController.h"

@interface BullshitDetailsViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong,nonatomic) IBOutlet UILabel *grade;
@end

@implementation BullshitDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.bullshitDict[@"recognized_text"]];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, [string.string length])];

    NSArray *words = self.bullshitDict[@"buzzwords"];
    
    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange searchRange = NSMakeRange(0, [string.string length]);
        
        NSRange range;
        while ((range = [string.string rangeOfString:obj options:NSCaseInsensitiveSearch range:searchRange]).location != NSNotFound) {
            
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:range];
            
            searchRange = NSMakeRange(NSMaxRange(range), [string.string length] - NSMaxRange(range));
        }
    }];
    
    self.textView.attributedText = string;
    
    self.grade.text = [NSString stringWithFormat:@"%.1f / 20", [self.bullshitDict[@"grade"]doubleValue]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)dismiss:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
