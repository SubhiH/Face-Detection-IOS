//
//  OpencvWrapper.m
//  face_detection
//
//  Created by Soubhi Hadri on 3/3/18.
//  Copyright © 2018 hadri. All rights reserved.
//

#import "OpencvWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/objdetect.hpp>

@implementation OpencvWrapper

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;
bool cascade_loaded = false;

+ (UIImage *)detect:(UIImage *)source {
    ///1. Convert input UIImage to Mat
    std::vector<cv::Rect> faces;
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    cv::Mat frame(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = frame.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(frame.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    cv::Mat frame_gray;
    
    cvtColor( frame, frame_gray, CV_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    
    ///2. detection
    NSString *eyes_cascade_name = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye" ofType:@"xml"];
    NSString *face_cascade_name = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
    if(!cascade_loaded){
        std::cout<<"loading ..";
        if( !eyes_cascade.load( std::string([eyes_cascade_name UTF8String]) ) ){ printf("--(!)Error loading\n"); return source;};
        if( !face_cascade.load( std::string([face_cascade_name UTF8String]) ) ){ printf("--(!)Error loading\n"); return source;};
        cascade_loaded = true;
    }
    face_cascade.detectMultiScale(frame_gray, faces, 1.3, 5);
    for( size_t i = 0; i < faces.size(); i++ )
    {
        cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 0, 100, 255 ), 4, 8, 0 );
        
        cv::Mat faceROI = frame_gray( faces[i] );
        std::vector<cv::Rect> eyes;
        
        //-- In each face, detect eyes
        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
        
        for( size_t j = 0; j < eyes.size(); j++ )
        {
            cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
            int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
            circle( frame, center, radius, cv::Scalar( 5, 255, 0 ), 2, 8, 0 );
        }
    }
    
    ///1. Convert Mat to UIImage
    NSData *data = [NSData dataWithBytes:frame.data length:frame.elemSize() * frame.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    bitsPerComponent = 8;
    bytesPerRow = frame.step[0];
    colorSpace = (frame.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    image = CGImageCreate(frame.cols, frame.rows, bitsPerComponent, bitsPerComponent * frame.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return result;
}


@end
