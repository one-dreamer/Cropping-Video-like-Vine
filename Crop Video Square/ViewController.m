//
//  Cropping Video Square Like Vine
//  Created by onedreamer pty ltd Feb/07/14
//

#import "ViewController.h"
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation ViewController
@synthesize mPlayer, mPlaybackView;


- (void)dealloc
{
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    //Call the Crop Video Methode
    [self CropVideoSquare];
}


- (void) CropVideoSquare{
    
    //load our movie Asset
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"OriginalVideo" ofType:@"mov"]]];
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
//    //Here we shift the viewing square up to the TOP of the video so we only see the top
//    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
//    
//    //Use this code if you want the viewing square to be in the middle of the video
//    //CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
//    
//    //Make sure the square is portrait
//    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
//    
//    CGAffineTransform finalTransform = t2;
//    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    [transformer setTransform:clipVideoTrack.preferredTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Create an Export Path to store the cropped video
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/CroppedVideo.mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:exportUrl error:nil];
    
    //Export
    exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
	
	[exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             [self exportDidFinish:exporter];
         });
     }];
}


- (void)exportDidFinish:(AVAssetExportSession*)session
{
    //Play the New Cropped video
    NSURL *outputURL = session.outputURL;
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:outputURL options:nil];
    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
}


- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (mPlayer.status == AVPlayerStatusReadyToPlay) {
         [self.mPlaybackView setPlayer:self.mPlayer];
        [self.mPlayer play];
    }
}
@end
