//
//  PDFPageRenderer.m
//
//  Created by Sorin Nistor on 3/21/11.
//  Copyright 2011 iPDFdev.com. All rights reserved.
//

#import "PDFPageRenderer.h"


@implementation PDFPageRenderer

+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context{
	[PDFPageRenderer renderPage:page inContext:context atPoint:CGPointMake(0, 0)];
}
	 
+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint:(CGPoint) point{
	[PDFPageRenderer renderPage:page inContext:context atPoint:point withZoom:100];
}

+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point withZoom: (float) zoom{
	
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int rotate = CGPDFPageGetRotationAngle(page);
	
	CGContextSaveGState(context);
	
	// Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	CGContextTranslateCTM(context, point.x, point.y);
	
	// Scale the page to desired zoom level.
	CGContextScaleCTM(context, zoom / 100, zoom / 100);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (rotate) {
		case 0:
			CGContextTranslateCTM(context, 0, cropBox.size.height);
			CGContextScaleCTM(context, 1, -1);
			break;
		case 90:
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -M_PI / 2);
			break;
		case 180:
		case -180:
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, cropBox.size.width, 0);
			CGContextRotateCTM(context, M_PI);
			break;
		case 270:
		case -90:
			CGContextTranslateCTM(context, cropBox.size.height, cropBox.size.width);
			CGContextRotateCTM(context, M_PI / 2);
			CGContextScaleCTM(context, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	CGContextAddRect(context, clipRect);
	CGContextClip(context);
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context, clipRect);
	
	CGContextTranslateCTM(context, -cropBox.origin.x, -cropBox.origin.y);
	
	CGContextDrawPDFPage(context, page);
	
	CGContextRestoreGState(context);
}

//- (void) stuff {
//    //This is defined previously and is the size
//    //we want to draw the document at. After all,
//    //PDF documents are meant to be vector content
//    //so they can be scaled at will.
//    CGSize drawingSize;
//
//    //Document Loading
//    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL(#URL#);
//    CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
//
//    //Start by getting the crop box since only
//    //its contents should be drawn
//    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
//
//    //Account for rotation of the page to figure
//    //out the size to create the context. Like images,
//    //rotation can be represented by one of two
//    //ways in a PDF: the contents can be pre-rotated
//    //in which case nothing needs to be done or the
//    //document can have its rotation value set and
//    //it means we need to apply the rotation as an
//    //affine transformation when drawing
//    NSInteger rotationAngle = CGPDFPageGetRotationAngle(page);
//    CGFloat angleInRadians = -rotationAngle * (M_PI / 180);
//    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
//    CGRect rotatedCropRect = CGRectApplyAffineTransform(cropBox, transform);
//
//    //Here we're figuring out the closest size we
//    //can draw the PDF at that's no larger than
//    //drawingSize
//    CGRect bestFit = BMBestFitFrameForSizeInRect(rotatedCropRect.size, CGRectMake(0.0, 0.0, drawingSize.width, drawingSize.height));
//    CGFloat scale = CGRectGetHeight(bestFit) / CGRectGetHeight(rotatedCropRect);
//    size_t width = (size_t) roundf(CGRectGetWidth(bestFit));
//    size_t height = (size_t) roundf(CGRectGetHeight(bestFit));
//    size_t bytesPerRow = ((width * 4) + 0x0000000F) & ~0x0000000F;
//
//    //Create the drawing context
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context =  CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little));
//    CGColorSpaceRelease(colorSpace);
//
//    //Fill the background color
//    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
//    CGContextFillRect(context, CGRectMake(0.0, 0.0, width, height));
//
//    //This portion is the core of drawing the PDF
//    //correctly and is seldom seen in any examples
//    //found online. This is where we create the
//    //affine transformation matrix to align the
//    //PDF's CropBox to our drawing context.
//    transform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, CGRectGetWidth(bestFit), CGRectGetHeight(bestFit)), 0, true);
//
//    if (scale > 1)
//    {
//        //Since CGPDFPageGetDrawingTransform won't
//        //scale up, we need to do it manually
//        transform = CGAffineTransformTranslate(transform, CGRectGetMidX(cropBox), CGRectGetMidY(cropBox));
//        transform = CGAffineTransformScale(transform, scale, scale);
//        transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(cropBox), -CGRectGetMidY(cropBox));
//    }
//
//    CGContextConcatCTM(context, transform);
//
//    //Clip the drawing to the CropBox
//    CGContextAddRect(context, cropBox);
//    CGContextClip(context);
//
//    CGContextDrawPDFPage(context, page);
//
//    CGImageRef result = CGBitmapContextCreateImage(context);
//    UIImage *resultUIImage = [UIImage imageWithCGImage:result];
//
//    CGContextRelease(context);
//    CGImageRelease(result);
//    CGPDFDocumentRelease(pdfDocument);
//}

+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context inRectangle: (CGRect) displayRectangle {
    if ((displayRectangle.size.width == 0) || (displayRectangle.size.height == 0)) {
        return;
    }
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int pageRotation = CGPDFPageGetRotationAngle(page);
	
	CGSize pageVisibleSize = CGSizeMake(cropBox.size.width, cropBox.size.height);
	if ((pageRotation == 90) || (pageRotation == 270) ||(pageRotation == -90)) {
		pageVisibleSize = CGSizeMake(cropBox.size.height, cropBox.size.width);
	}
    
    float scaleX = displayRectangle.size.width / pageVisibleSize.width;
    float scaleY = displayRectangle.size.height / pageVisibleSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Offset relative to top left corner of rectangle where the page will be displayed
    float offsetX = 0;
    float offsetY = 0;
    
    float rectangleAspectRatio = displayRectangle.size.width / displayRectangle.size.height;
    float pageAspectRatio = pageVisibleSize.width / pageVisibleSize.height;
    
    if (pageAspectRatio < rectangleAspectRatio) {
        // The page is narrower than the rectangle, we place it at center on the horizontal
        offsetX = (displayRectangle.size.width - pageVisibleSize.width * scale) / 2;
    }
    else { 
        // The page is wider than the rectangle, we place it at center on the vertical
        offsetY = (displayRectangle.size.height - pageVisibleSize.height * scale) / 2;
    }
    
    CGPoint topLeftPage = CGPointMake(displayRectangle.origin.x + offsetX, displayRectangle.origin.y + offsetY);
    
    [PDFPageRenderer renderPage:page inContext:context atPoint:topLeftPage withZoom:scale * 100];
}

@end
