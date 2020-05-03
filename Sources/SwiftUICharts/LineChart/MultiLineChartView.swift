//
//  File.swift
//  
//
//  Created by Samu András on 2020. 02. 19..
//

import SwiftUI

public struct MultiLineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var data: [MultiLineChartData]
    public var title: String
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle

    private var numberFormatter: NumberFormatter
    
    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if oldValue != self.currentValue && showIndicatorDot {
                HapticFeedback.playSelection()
            }
        }
    }
    
    var globalMin: Double {
        if let min = data.flatMap({$0.onlyPoints()}).min() {
            return min
        }
        return 0
    }
    
    var globalMax: Double {
        if let max = data.flatMap({$0.onlyPoints()}).max() {
            return max
        }
        return 0
    }
    
    public init(data: [[Double]],
                title: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                numberFormatter: NumberFormatter = NumberFormatter()) {
        var pairs: [([Double], GradientColor)] = []
        let colourCount = GradientColors.all.count
        for i in 0..<data.count {
            pairs.append((data[i], GradientColors.all[i % colourCount]))
        }
        self.init(data: pairs, title: title, style: style, numberFormatter: numberFormatter)
    }
    
    public init(data: [([Double], GradientColor)],
                title: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                numberFormatter: NumberFormatter = NumberFormatter()) {
        
        var d: [MultiLineChartData] = []
        for i in 0..<data.count {
            let series = data[i]
            d.append(MultiLineChartData(points: series.0, gradient: series.1, index: i))
        }
        self.data = d
        self.title = title ?? ""
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.numberFormatter = numberFormatter
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(self.title)
                            .font(.subheadline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.1))
                    .padding([.leading, .top])
                    Spacer()
                }
                ZStack{
                    ForEach(self.data) { series in
                        Line(data: series,
                             frame: .constant(geo.frame(in: .local)),
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$showIndicatorDot,
                             minDataValue: .constant(self.globalMin),
                             maxDataValue: .constant(self.globalMax),
                             showBackground: false,
                             gradient: series.getGradient(),
                             index: series.index)
                    }
                }
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
    //            self.touchLocation = value.location
    //            self.showIndicatorDot = true
    //            self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height)
            })
                .onEnded({ value in
                    self.showIndicatorDot = false
                })
            )
        }
    }
    
//    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
//        let points = self.data.onlyPoints()
//        let stepWidth: CGFloat = width / CGFloat(points.count-1)
//        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
//
//        let index:Int = Int(round((toPoint.x)/stepWidth))
//        if (index >= 0 && index < points.count){
//            self.currentValue = points[index]
//            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
//        }
//        return .zero
//    }
}

struct MultiLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultiLineChartView(data: [([8,23,54,32,12,37,7,23,43], GradientColors.orange)], title: "Line chart")
                .environment(\.colorScheme, .light)
        }
    }
}
