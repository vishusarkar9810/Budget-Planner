import SwiftUI

struct PremiumBannerView: View {
    @State private var isShowingSubscriptionView = false
    var featureName: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Premium Feature")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("Unlock \(featureName) and more premium features")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                isShowingSubscriptionView = true
            } label: {
                Text("Upgrade to Premium")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .sheet(isPresented: $isShowingSubscriptionView) {
            SubscriptionView()
        }
    }
}

struct PremiumFeatureOverlay: View {
    @State private var isShowingSubscriptionView = false
    var featureName: String
    
    var body: some View {
        ZStack {
            // Blurred background
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .background(.ultraThinMaterial)
            
            // Premium content
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("\(featureName) is a Premium Feature")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Subscribe to unlock this and other premium features")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button {
                    isShowingSubscriptionView = true
                } label: {
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
        }
        .sheet(isPresented: $isShowingSubscriptionView) {
            SubscriptionView()
        }
    }
}

// A modifier to gate premium features
struct PremiumFeatureModifier: ViewModifier {
    var isSubscribed: Bool
    var featureName: String
    
    func body(content: Content) -> some View {
        if isSubscribed {
            content
        } else {
            PremiumFeatureOverlay(featureName: featureName)
        }
    }
}

extension View {
    func premiumFeature(isSubscribed: Bool, featureName: String) -> some View {
        modifier(PremiumFeatureModifier(isSubscribed: isSubscribed, featureName: featureName))
    }
}

#Preview {
    VStack {
        PremiumBannerView(featureName: "Advanced Analytics")
            .padding()
        
        Color.gray.opacity(0.2)
            .frame(height: 300)
            .overlay {
                PremiumFeatureOverlay(featureName: "Advanced Analytics")
            }
    }
} 