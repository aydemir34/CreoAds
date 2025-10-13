// FocusSparklesView.swift

import SwiftUI

struct SparklesView: View {
    @ObservedObject var engine: FocusSparkleEngine
    
        var body: some View {
        
            Canvas { context, size in
            
            for sparkle in engine.sparkles {
                    guard sparkle.opacity > 0.05 else { continue }

                    let frame = CGRect(x: sparkle.position.x - (8 * sparkle.scale) / 2,
                                    y: sparkle.position.y - (8 * sparkle.scale) / 2,
                                    width: 8 * sparkle.scale,
                                    height: 8 * sparkle.scale)
                                
                        context.fill(Path(ellipseIn: frame), with: .color(Color.yellow.opacity(sparkle.opacity * 0.9)))
                        let haloFrame = frame.insetBy(dx: -frame.width * 0.3, dy: -frame.height * 0.3)
                        context.fill(Path(ellipseIn: haloFrame), with: .color(Color.orange.opacity(sparkle.opacity * 0.3)))
                    }
                }
            .allowsHitTesting(false)
 
                }
            }
