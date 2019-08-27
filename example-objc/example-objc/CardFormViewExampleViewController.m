//
//  CardFormViewExampleViewController.m
//  example-objc
//
//  Created by Li-Hsuan Chen on 2019/07/23.
//  Copyright © 2019 PAY, Inc. All rights reserved.
//

#import "CardFormViewExampleViewController.h"
@import PAYJP;

@interface CardFormViewExampleViewController ()

@property (weak, nonatomic) IBOutlet PAYCardFormView *cardFormView;
@property (weak, nonatomic) IBOutlet UILabel *tokenIdLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *createTokenButton;

@property (strong, nonatomic) PAYAPIClient *payjpClient;

@end

@implementation CardFormViewExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardFormView.delegate = self;
    
    self.createTokenButton.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.createTokenButton setUserInteractionEnabled:NO];
    self.createTokenButton.contentView.alpha = 0.5;
}
    
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
        sectionName = NSLocalizedString(@"example_card_information_section", nil);
        break;
        case 2:
        sectionName = NSLocalizedString(@"example_token_id_section", nil);
        break;
        default:
        break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Create Token
    if (indexPath.section == 1 && indexPath.row == 0) {
        // TODO: call createToken
    }
    // Create Token Anyway
    if (indexPath.section == 1 && indexPath.row == 1) {
        BOOL isValid = [self.cardFormView validateCardForm];
        if (isValid) {
            // TODO: call createToken
        }
    }
}

- (void)inputValidated {
    BOOL isValid = [self.cardFormView isValid];
    if (isValid) {
        self.createTokenButton.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self.createTokenButton setUserInteractionEnabled:YES];
        self.createTokenButton.contentView.alpha = 1.0;
    } else {
        self.createTokenButton.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.createTokenButton setUserInteractionEnabled:NO];
        self.createTokenButton.contentView.alpha = 0.5;
    }
}

@end
