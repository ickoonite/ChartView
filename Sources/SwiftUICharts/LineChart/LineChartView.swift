//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data: ChartData
    public var title: String
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    
    public var numberFormatter: NumberFormatter
    
    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if oldValue != self.currentValue && showIndicatorDot {
                HapticFeedback.playSelection()
            }
        }
    }

    public init(data: [Double],
                title: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                numberFormatter: NumberFormatter = NumberFormatter()) {
        
        self.data = ChartData(points: data)
        self.title = title ?? ""
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.numberFormatter = numberFormatter
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8){
                        Text(self.title)
                            .font(.subheadline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.1))
                    .padding([.leading, .top])
                    Spacer()
                }
                Line(data: self.data,
                    frame: .constant(geo.frame(in: .local)),
                    touchLocation: self.$touchLocation,
                    showIndicator: self.$showIndicatorDot,
                    minDataValue: .constant(nil),
                    maxDataValue: .constant(nil)
                )
                .frame(width: geo.size.width, height: geo.size.height)
                if self.showIndicatorDot {
                    HStack{
                        Spacer()
                        Text(self.numberFormatter.string(from: NSNumber(value: self.currentValue)) ?? "")
                            .font(.headline)
                        Spacer()
                    }
                    .transition(.scale)
                }
            }
            .gesture(DragGesture()
            .onChanged({ value in
                self.touchLocation = value.location
                self.showIndicatorDot = true
                self.getClosestDataPoint(toPoint: value.location, width:geo.size.width, height: geo.size.height)
            })
            .onEnded({ value in
                self.showIndicatorDot = false
            })
            )
        }.frame(minWidth: 120, idealWidth: 200, maxWidth: .infinity, minHeight: 60, idealHeight: 200, maxHeight: .infinity, alignment: .center)
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineChartView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart")
                .environment(\.colorScheme, .light)
        }.previewLayout(.fixed(width: 480, height: 240))
    }
}
