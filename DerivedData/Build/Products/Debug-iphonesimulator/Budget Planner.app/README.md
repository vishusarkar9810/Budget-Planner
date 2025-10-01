# Budget Planner App

A modern iOS app for tracking expenses, setting budgets, and analyzing your spending patterns.

## Onboarding Screens with Animations

The app includes animated onboarding screens that demonstrate key features with engaging animations, similar to the examples shown in the design mockups.

### Implementation Details

The onboarding screens use two approaches for animations:

1. **Native SwiftUI Animations**: Using transitions, scaling, opacity, and other SwiftUI animation features
2. **Custom Animation System**: For more complex animations like the GIF examples in the mockups

### How to Add Real GIF Support

The current implementation includes placeholder views for GIFs. To implement real GIF support:

#### Option 1: Using SDWebImageSwiftUI (Recommended)

1. Add the package dependency:
   ```swift
   // In Xcode: File > Swift Packages > Add Package Dependency
   // URL: https://github.com/SDWebImage/SDWebImageSwiftUI.git
   ```

2. Import the library and replace the `GIFImageView` with:
   ```swift
   import SDWebImageSwiftUI

   // Replace the placeholder view with this:
   WebImage(url: URL(string: "https://example.com/image.gif"))
     .resizable()
     .indicator(.activity)
     .transition(.fade)
     .scaledToFit()
   ```

3. For local GIFs, add them to your asset catalog and use:
   ```swift
   AnimatedImage(name: "animation.gif")
     .resizable()
     .scaledToFit()
   ```

#### Option 2: Using SwiftyGif

1. Add the package dependency:
   ```swift
   // In Xcode: File > Swift Packages > Add Package Dependency
   // URL: https://github.com/kirualex/SwiftyGif.git
   ```

2. Create a GIF wrapper view:
   ```swift
   import SwiftyGif
   import SwiftUI

   struct GIFView: UIViewRepresentable {
       let gifName: String
       
       func makeUIView(context: Context) -> UIImageView {
           let imageView = UIImageView()
           do {
               let gif = try UIImage(gifName: gifName)
               imageView.setGifImage(gif)
               imageView.contentMode = .scaleAspectFit
           } catch {
               print("Error loading GIF: \(error)")
           }
           return imageView
       }
       
       func updateUIView(_ uiView: UIImageView, context: Context) {}
   }
   ```

3. Use it in your views:
   ```swift
   GIFView(gifName: "animation.gif")
       .frame(width: 300, height: 300)
   ```

### GIF Animation File Naming

For the onboarding screen animations, add the following GIF files to your project:

1. `budget_chart_animation.gif` - For the first screen showing budget tracking
2. `budget_person_animation.gif` - For the second screen showing financial journey
3. `user_testimonial.gif` - For the user testimonial animation

### Performance Considerations

- GIF animations can impact performance and battery life
- Consider limiting the number of concurrent GIF animations
- For complex animations, consider using Lottie instead of GIFs
- Test on different device models to ensure smooth performance

## Custom Animation Sequences

The `AnimationManager` class provides a way to play a sequence of images as an animation, which can be an alternative to GIFs:

1. Create a sequence of images (e.g., frame1.png, frame2.png, etc.)
2. Use the `AnimatedImageView` component:
   ```swift
   AnimatedImageView(
       animationBaseName: "animation_prefix",
       frameCount: 30,
       fps: 24
   )
   ```

## Example Usage

```swift
// In your onboarding view:
switch page.animationType {
case .chart:
    // Using GIF
    AnimatedImage(name: "budget_chart_animation.gif")
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 380)
    
case .budget:
    // Using image sequence
    AnimatedImageView(
        animationBaseName: "budget_animation",
        frameCount: 24,
        fps: 24
    )
    .frame(width: 300, height: 300)
}
```

## Credits

- Design inspiration from modern fitness tracking apps
- Icons from SF Symbols 