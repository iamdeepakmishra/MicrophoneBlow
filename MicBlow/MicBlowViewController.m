//
//  MicBlowViewController.m
//  MicBlow
//
//  Created by deepak mishra on 2/5/13.
//

#import "MicBlowViewController.h"

#define FINISH_POINT    45      // y coordinate
#define LIMITED_TIME    30.0    // in secs

@interface MicBlowViewController ()<UIAlertViewDelegate>
@property (nonatomic, retain)AVAudioRecorder *recorder;
@property (nonatomic, retain)NSTimer *levelTimer;//----------------- FIRES CONTINOUSLY TO CAPTURE USER'S BLOW 
@property (nonatomic, assign)double lowPassResults;//--------------- FOR THRESHOLD BLOW
@property (retain, nonatomic) NSTimer *limitedTimer;//-------------- IN CASE USER DOESN'T DO ANYTHING, WE RESET THE UI AND TIMERS
@property (assign, nonatomic) IBOutlet UILabel *ballObject;
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UIButton *resetButton;
@property (assign, nonatomic) double timeLimitCounter;

-(void)callingAlertWithMessage:(NSString *)message;
-(void)limitedTimeReached:(NSTimer *)timer;
- (void)levelTimerCallback:(NSTimer *)timer;
@end

@implementation MicBlowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // URL WHERE WE SAVED THE AUDIO FILE CAPTURED BUT AS HERE ITS NOT OF OUR USE SO WE WILL NOT SAVE ANY
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    // SOME SETTINGS OF AUDIO RECORDER
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    NSError *err;
    AVAudioRecorder *rec = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    self.recorder = rec;
    [rec release];
}

-(void)callingAlertWithMessage:(NSString *)message
{
    [self.levelTimer invalidate];
    [self.limitedTimer invalidate];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    alert = nil;
}


//*******************************************//
#pragma mark - TIMER CALLBACKS
//*******************************************//
- (void)levelTimerCallback:(NSTimer *)timer
{
    self.timeLimitCounter += [timer timeInterval];
    
    [self.recorder updateMeters]; //OBTAINING CURRENT AUDIO POWER
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
	self.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults; // ADDING SOME FILTERS
    
    if(self.lowPassResults > 0.95) // THRESHOLD LIMIT OF BLOWING IN THE MIC
    {
        [self.ballObject setFrame:CGRectMake(self.ballObject.frame.origin.x,
                                             self.ballObject.frame.origin.y - 1.5,
                                             self.ballObject.frame.size.width,
                                             self.ballObject.frame.size.height)];
        if(self.ballObject.frame.origin.y <= FINISH_POINT)
        {
            [self callingAlertWithMessage:[NSString stringWithFormat:@"You have finished in %0.2lf secs",self.timeLimitCounter]];
        }
    }
}

-(void)limitedTimeReached:(NSTimer *)timer
{
    [self callingAlertWithMessage:@"Time Over!"];
}


//*******************************************//
#pragma mark - START and RESET
//*******************************************//
- (IBAction)startTheBlow:(UIButton *)sender
{
    self.timeLimitCounter = 0; // TIME COUNTER
    self.limitedTimer = [NSTimer scheduledTimerWithTimeInterval:LIMITED_TIME target:self selector:@selector(limitedTimeReached:) userInfo:nil repeats:NO];
    
    [self.startButton setEnabled:NO];
    [self.resetButton setEnabled:YES];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else
        NSLog(@"ERROR");
}

- (IBAction)resetTheBlow:(UIButton *)sender
{
    [self.startButton setEnabled:YES];
    [self.resetButton setEnabled:NO];
    
    [self.levelTimer invalidate];
    [self.limitedTimer invalidate];
    [self.ballObject setFrame:CGRectMake(self.ballObject.frame.origin.x,
                                         self.view.frame.size.height - 88,
                                         self.ballObject.frame.size.width,
                                         self.ballObject.frame.size.height)];
}


//*******************************************//
#pragma mark - ALERTVIEW DELEGATE METHOD
//*******************************************//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.ballObject setFrame:CGRectMake(self.ballObject.frame.origin.x,
                                             self.view.frame.size.height - 88,
                                             self.ballObject.frame.size.width,
                                             self.ballObject.frame.size.height)];
        [self.startButton setEnabled:YES];
        [self.resetButton setEnabled:NO];
    }
}


//*******************************************//
#pragma mark - MEMORY MANAGEMENT
//*******************************************//
- (void)viewDidUnload
{
    [self setStartButton:nil];
    [self setResetButton:nil];
    [super viewDidUnload];
}

-(void)dealloc
{
    [_limitedTimer release];
    [_levelTimer release];
    [_recorder release];
    [_startButton release];
    [_resetButton release];
    [super dealloc];
}

@end
