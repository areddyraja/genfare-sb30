//
//  PurchasePassesViewController.m
//  CDTATicketing
//
//  Created by Reddy Raja on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "PurchasePassesViewController.h"
#import "NSData+CRC32.h"
#import "CooCooBase.h"

@interface PurchasePassesViewController (){
     IBOutlet UIButton *dismissButton;
}

@end


/*StringBuilder barcodeBuilder=new StringBuilder();
barcodeBuilder.append(fillString(signature,3,true));
barcodeBuilder.append(fillString(DataPreference.readData(this,DataPreference.AGENCY_ID),4,false));
barcodeBuilder.append(fillString(fileVersion,2,false));
barcodeBuilder.append(fillString(walletID,51,true));
barcodeBuilder.append(fillString(RFU,7,true));
String crc = CRC_32.crc32(barcodeBuilder.toString());
Log.d("BARCODE_STRING",crc);
barcodeBuilder.append(crc);
Log.d("BARCODE_STRING",barcodeBuilder.toString());

Bitmap barcode=TicketPagerActivity.createQrCode(barcodeBuilder.toString(),500,500);
Log.d("BARCODE_STRING",barcode.toString());
barcode_rpl.setImageBitmap(barcode);
*/
@implementation PurchasePassesViewController
@synthesize qrImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dismissButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities continueButtonBgColor]]];
    [self setTitle:@"Purchase Passes"];
    NSString *strCRC;
    NSString *walletIdNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"WALLETPRINT_ID"];
    NSInteger charCount = 51-walletIdNum.length;
    if(charCount>0)
    {
        for (int i=0; i<charCount; i++) {
            walletIdNum = [walletIdNum stringByAppendingString:@"0"];
        }
    }
    NSNumber *agencyIdNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"AGENCY_ID"];
    if(agencyIdNum.stringValue.length == 3)
    {
        
        NSString *strId = [NSString stringWithFormat:@"0%@",agencyIdNum];
        strCRC = [self GenerareStringforCRC:walletIdNum AgencyId:strId];
    }
    else
    {
        strCRC = [self GenerareStringforCRC:walletIdNum AgencyId:agencyIdNum.stringValue];
        
    }
   
    NSString *CRC32 = [self GenerateCRCnumber:@"GEN019406B08AA158B8937670000000000000000000000000000000000000000000"];
    

    [self generateQRCodeImage:[NSString stringWithFormat:@"%@%@",strCRC,CRC32.uppercaseString]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString *)GenerareStringforCRC:(NSString *)walletId  AgencyId:(NSString *)AgencyId
{
    NSString *strCRC = [NSString stringWithFormat:@"%@"@"%@"@"%@"@"%@"@"%@",@"GEN",AgencyId,@"01",walletId,@"0000000"];
    
    return strCRC;
}

-(NSString *)GenerateCRCnumber:(NSString *)StrCRC
{
    NSString *checksum;
    NSData *data = [StrCRC dataUsingEncoding:NSUTF8StringEncoding];
    checksum = [data CRC32];
    
    return checksum;
}
- (void)generateQRCodeImage:(NSString *)strInput
{
    NSString *qrString = strInput;
    NSData *stringData = [qrString dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.qrImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.qrImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    self.qrImageView.image = [UIImage imageWithCIImage:qrImage
                                                 scale:[UIScreen mainScreen].scale
                                           orientation:UIImageOrientationUp];
}

- (IBAction)btnDismissTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
