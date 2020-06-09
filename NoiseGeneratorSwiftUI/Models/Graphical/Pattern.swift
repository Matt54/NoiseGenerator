import Foundation
import SwiftUI

public class Pattern : ObservableObject{
    
    var pointProximity: CGFloat = 0.1
    var numberOfPoints: Int
    var points: [PathPoint] = []
    var intersectionPoints: [Point] = []
    var controlPoints: [Point] = []
    
    var selectedPoint: Point?
    var selectedPosition: Int?
    var selectedPointType: PointType?
    
    var isNewPoint: Bool = false
    var lockMove: Bool = false
    var lastTouchY: CGFloat = 0
    
    var displayValuePoint = CGPoint(x: 0.0, y: 0.0)
    
    var modulationColor: Color
    
    init(color: Color){
        // Set initial number of points
        numberOfPoints = 0
        modulationColor = color
        
        // Add first two points
        self.addPoint(newPointCoordinate: CGPoint(x: 0.0, y: 1.0))
        self.addPoint(newPointCoordinate: CGPoint(x: 1.0, y: 0.0))
        
        // Manually set first control point
        resetControlPoint(1)
    }
    
    
    func getValueFromX(xVal: CGFloat) -> CGFloat{
        
        let rightHandIndex = binarySearchForRightHandIndex(xVal: xVal)
        
        let xRange:CGFloat = points[rightHandIndex].coordinate.x - points[rightHandIndex - 1].coordinate.x
        
        let normalizedX:CGFloat = (xVal - points[rightHandIndex - 1].coordinate.x) / xRange

        
        let yInt = determineIntersectionY(x: normalizedX,
                                          y1: points[rightHandIndex - 1].coordinate.y,
                                          y2: points[rightHandIndex].controlPoint1!.coordinate.y,
                                          y3: points[rightHandIndex].controlPoint2!.coordinate.y,
                                          y4: points[rightHandIndex].coordinate.y)
        
        displayValuePoint.x = xVal
        displayValuePoint.y = yInt
        
        return 1.0 - yInt
    }
    
    
    func binarySearchForRightHandIndex(xVal: CGFloat) -> Int{
        var lowerIndex = 0;
        var upperIndex = points.count - 1
        
        while (true) {
            
            //I think what is happening here is that a point is removed while the modulation is firing this
            //A solution may be to lock this function while a delete it occuring -  this would involve:
            // - pattern telling it's modulation about the delete - this function is prevented from occuring
            // - delete continuing to adjust it's xVal without adjustment yVal
            // - pattern tells it's modulation that it is done with delete - this function is no longer prevented
            
            // I think there are cases here when this mixes up the lower and upper?
            // lowerIndex = 5
            // upperIndex = 4
            let currentIndex = (lowerIndex + upperIndex) / 2
            
            // Thread 28: Fatal error: Index out of range
            // I was trying to delete the second last point.. I had 5 points
            if( (points[currentIndex].coordinate.x > xVal)
                && (points[currentIndex - 1].coordinate.x < xVal) ){
                return currentIndex
            }
            else{
                if (points[currentIndex].coordinate.x > xVal) {
                    upperIndex = currentIndex - 1
                }
                else{
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    func analyzeTouch(graphCoordinate: CGPoint, graphSize: CGSize, touchState: TouchState){
        print(touchState)
        
        if(touchState == .began){
            analyzePoint(graphCoordinate: graphCoordinate, graphSize: graphSize)
        }
        else if(touchState == .moved){
            if(!lockMove){
                
                if(selectedPointType == .path){
                    movePathPoint(graphCoordinate: graphCoordinate, graphSize: graphSize)
                }
                else if(selectedPointType == .control){
                    dragIntersectionPoint(graphCoordinate: graphCoordinate, graphSize: graphSize)
                }
            }
        }
        else if(touchState == .ended){
            isNewPoint = false
        }
    }
    
    func analyzePoint(graphCoordinate: CGPoint, graphSize: CGSize){
        var translatedCoordinate = CGPoint(x: graphCoordinate.x / graphSize.width, y: graphCoordinate.y / graphSize.height)
        
        translatedCoordinate.x = min(max(translatedCoordinate.x, 0), 1.0)
        translatedCoordinate.y = min(max(translatedCoordinate.y, 0), 1.0)
        
        lastTouchY = translatedCoordinate.y
        
        let isInProximity = checkPoint(coordinateToCheck: translatedCoordinate)
        
        if(!isInProximity){
            addPoint(newPointCoordinate: translatedCoordinate)
        }
        
        lockMove = false
    }
    
    func checkPoint(coordinateToCheck: CGPoint) -> Bool{
        for point in points {
            if(distanceBetweenTwoPoints(point.coordinate, coordinateToCheck) < pointProximity){
                selectedPoint = point
                selectedPointType = .path
                selectedPosition = findPointPosition(point: point)
                return true
            }
            else if(point.intersectionPoint != nil){
                if(distanceBetweenTwoPoints(point.intersectionPoint!.coordinate, coordinateToCheck) < pointProximity){
                    selectedPoint = point.intersectionPoint
                    selectedPointType = .control
                    selectedPosition = findPointPosition(point: point)
                    return true
                }
            }
        }
        selectedPoint = nil
        return false
    }
    
    func movePathPoint(graphCoordinate: CGPoint, graphSize: CGSize){
        var translatedCoordinate = CGPoint(x: graphCoordinate.x / graphSize.width, y: graphCoordinate.y / graphSize.height)
        
        //clamp to min of 0, max of 1.0
        translatedCoordinate.y = min(max(translatedCoordinate.y, 0), 1.0)
        
        if(selectedPoint!.id > 2){
            translatedCoordinate.x = min(max(translatedCoordinate.x,points[selectedPosition!-1].coordinate.x), points[selectedPosition!+1].coordinate.x)
            adjustSurroundingControlPoints(xTranslated: selectedPoint!.coordinate.x - translatedCoordinate.x,
                                           yTranslated: selectedPoint!.coordinate.y - translatedCoordinate.y)
        }
        else if(selectedPoint!.id == 2){
            translatedCoordinate.x = 1.0
            adjustControlPointsLeft(xMove: 0,
                                    yMove: selectedPoint!.coordinate.y - translatedCoordinate.y,
                                    p1: points[selectedPosition!-1],
                                    p2: points[selectedPosition!])
        }
        else{
            translatedCoordinate.x = 0.0
            adjustControlPointsRight(xMove: 0,
                                     yMove: selectedPoint!.coordinate.y - translatedCoordinate.y,
                                     p1: points[selectedPosition!],
                                     p2: points[selectedPosition!+1])
        }

        selectedPoint?.coordinate = translatedCoordinate
    }
    
    func dragIntersectionPoint(graphCoordinate: CGPoint, graphSize: CGSize){

        // Just get the change in the y direction
        var translatedCoordinate = CGPoint(x: graphCoordinate.x / graphSize.width, y: graphCoordinate.y / graphSize.height)
        translatedCoordinate.x = 0
        let deltaY = lastTouchY - translatedCoordinate.y
        
        // use the deltaY to set control point values (going to be a lot to this)
        dragControlPoints(deltaY)
        
        // set the new intersection point value
        setNewIntersectionPoint(p1: points[selectedPosition!-1], p2: points[selectedPosition!])
        
        // set the deltaY to the new coordinate
        lastTouchY = translatedCoordinate.y
    }
    
    /**
        Adjusts the curve between two points by moving control points
     - Parameter y: The distance to adjust one of the curve's control points.
     */
    func dragControlPoints(_ y: CGFloat){
        
        let bounds = getMinMax(p1: points[selectedPosition!-1], p2: points[selectedPosition!]) // 0 - min, 1 - max
        
        // Determine which point is the higher point
        let maxP = (points[selectedPosition!].coordinate.y < points[selectedPosition!-1].coordinate.y) ? points[selectedPosition!] : points[selectedPosition!-1]
        let minP = (points[selectedPosition!] === maxP) ? points[selectedPosition!-1] : points[selectedPosition!]
        
        // Determine if our points are ramping up or down
        let isRampUp = (points[selectedPosition!] === maxP)
        
        // Determine the min/max control points
        let maxCP = isRampUp ? points[selectedPosition!].controlPoint2 : points[selectedPosition!].controlPoint1
        let minCP = isRampUp ? points[selectedPosition!].controlPoint1 : points[selectedPosition!].controlPoint2
        
        // Determine what the delta y is
        let deltaY = maxP.coordinate.y - minP.coordinate.y
        
        // Get the intermediate control points that turn the curve into a straight line
        let minLinearPos = minP.coordinate.y + deltaY / 3
        let maxLinearPos = maxP.coordinate.y - deltaY / 3
        
        //down
        if(y < 0){
            
            // Check if minimum is above linear position - if not, move minimum towards linear position
            if((minCP?.coordinate.y)! < minLinearPos){
                minCP!.coordinate.y = min(minCP!.coordinate.y - y, minLinearPos)
            }
            
            // Check if maximum is above linear position - if not, move maximum towards linear position
            else if((maxCP?.coordinate.y)! < maxLinearPos){
                maxCP!.coordinate.y = min(maxCP!.coordinate.y - y, maxLinearPos)
            }
            
            // Check if minimum is at extreme - if not, move minimum towards extreme
            else if((minCP?.coordinate.y)! < bounds[1]){
                minCP!.coordinate.y = min(minCP!.coordinate.y - y, bounds[1])
            }
            
            // Move maximum towards extreme
            else{
                maxCP!.coordinate.y = min(maxCP!.coordinate.y - y, bounds[1])
            }
        }
            
        //up
        else{
            
            // Check if maximum is above linear position - if not, move maximum towards linear position
            if((maxCP?.coordinate.y)! > maxLinearPos){
                maxCP!.coordinate.y = max(maxCP!.coordinate.y - y, maxLinearPos)
            }
            
            // Check if minimum is above linear position - if not, move minimum towards linear position
            else if((minCP?.coordinate.y)! > minLinearPos){
                minCP!.coordinate.y = max(minCP!.coordinate.y - y, minLinearPos)
            }
            
            // Check if maximum is at extreme - if not, move maximum towards extreme
            else if((maxCP?.coordinate.y)! > bounds[0]){
                maxCP!.coordinate.y = max(maxCP!.coordinate.y - y, bounds[0])
            }
            
            // Move maximum towards extreme
            else{
                minCP!.coordinate.y = max(minCP!.coordinate.y - y, bounds[0])
            }
        }
        
    }
    
    func adjustSurroundingControlPoints(xTranslated: CGFloat, yTranslated: CGFloat){
        adjustControlPointsLeft(xMove: xTranslated, yMove: yTranslated, p1: points[selectedPosition!-1], p2: points[selectedPosition!])
        adjustControlPointsRight(xMove: xTranslated, yMove: yTranslated, p1: points[selectedPosition!], p2: points[selectedPosition!+1])
    }
    
    func adjustControlPointsLeft(xMove: CGFloat, yMove: CGFloat, p1: PathPoint, p2: PathPoint){
        
        p2.controlPoint1!.coordinate.x = p2.controlPoint1!.coordinate.x - xMove * (1/3)
        p2.controlPoint2!.coordinate.x = p2.controlPoint2!.coordinate.x - xMove * (2/3)
        
        let bounds = getMinMax(p1: p1, p2: p2) // 0 - min, 1 - max
        p2.controlPoint1!.coordinate.y = min(max(p2.controlPoint1!.coordinate.y - yMove * (1/3),bounds[0]),bounds[1])
        p2.controlPoint2!.coordinate.y = min(max(p2.controlPoint2!.coordinate.y - yMove * (2/3),bounds[0]),bounds[1])
        
        setNewIntersectionPoint(p1: p1, p2: p2)
    }
    
    func adjustControlPointsRight(xMove: CGFloat, yMove: CGFloat, p1: PathPoint, p2: PathPoint){
        
        p2.controlPoint2!.coordinate.x = p2.controlPoint2!.coordinate.x - xMove * (1/3)
        p2.controlPoint1!.coordinate.x = p2.controlPoint1!.coordinate.x - xMove * (2/3)

        let bounds = getMinMax(p1: p1, p2: p2) // 0 - min, 1 - max
        p2.controlPoint2!.coordinate.y = min(max(p2.controlPoint2!.coordinate.y - yMove * (1/3),bounds[0]),bounds[1])
        p2.controlPoint1!.coordinate.y = min(max(p2.controlPoint1!.coordinate.y - yMove * (2/3),bounds[0]),bounds[1])
        
        setNewIntersectionPoint(p1: p1, p2: p2)
    }
    
    func getMinMax(p1: PathPoint, p2: PathPoint) -> [CGFloat]{
        if(p2.coordinate.y > p1.coordinate.y){
            return [p1.coordinate.y , p2.coordinate.y]
        }
        else{
            return [p2.coordinate.y , p1.coordinate.y]
        }
    }
    
    func setNewIntersectionPoint(p1: PathPoint, p2: PathPoint){
        let yInt = determineIntersectionY(x: 0.5,
                                          y1: p1.coordinate.y,
                                          y2: p2.controlPoint1!.coordinate.y,
                                          y3: p2.controlPoint2!.coordinate.y,
                                          y4: p2.coordinate.y)
        
        if(p2.intersectionPoint == nil){
            let intersectionPointCoordinate = CGPoint(x: (p2.coordinate.x + p1.coordinate.x)/2, y: yInt)
            numberOfPoints = numberOfPoints + 1
            p2.intersectionPoint = Point(coordinate: intersectionPointCoordinate, id: numberOfPoints)
            
            print("intersection point:")
            print(intersectionPointCoordinate)
        }
        else{
        p2.intersectionPoint!.coordinate = CGPoint(x: (p2.coordinate.x + p1.coordinate.x)/2, y: yInt)
        }
    }
    
    func findPointPosition(point: Point) -> Int{
        for n in 0...(numberOfPoints - 1) {
            if(point === points[n]){
                return n
            }
        }
        return -1
    }
    
    func addPoint(newPointCoordinate: CGPoint){

        numberOfPoints = numberOfPoints + 1
        let newPoint = PathPoint(coordinate: newPointCoordinate, id: numberOfPoints)

        if(numberOfPoints < 3){
            points.append(newPoint)
        }
        else{
            controlPoints.removeAll()
            
            let placement = determinePointPlacement(newPointCoordinate)
            points.insert(newPoint, at: placement)
            selectedPosition = placement
            resetControlPoint(selectedPosition!)
            resetControlPoint(selectedPosition! + 1)
        }
        selectedPoint = newPoint
        isNewPoint = true
    }
    
    ///Create control point between point and previous point
    func resetControlPoint(_ position: Int){
        let controlPointCoordinate1 =
            CGPoint(x: points[position-1].coordinate.x + (points[position].coordinate.x - points[position-1].coordinate.x) * (1/3),// * 0.25,
                    y: points[position-1].coordinate.y + (points[position].coordinate.y - points[position-1].coordinate.y) * (1/3))//* 0.25)
        
        let controlPointCoordinate2 =
            CGPoint(x: points[position-1].coordinate.x + (points[position].coordinate.x - points[position-1].coordinate.x) * (2/3),//* 0.75,
                    y: points[position-1].coordinate.y + (points[position].coordinate.y - points[position-1].coordinate.y) * (2/3))//* 0.75)
        
        print("controlPointCoordinate1:")
        print(controlPointCoordinate1)
        
        print("controlPointCoordinate2:")
        print(controlPointCoordinate2)
        
        numberOfPoints = numberOfPoints + 1
        let controlPoint1 = Point(coordinate: controlPointCoordinate1, id: numberOfPoints)
        
        numberOfPoints = numberOfPoints + 1
        let controlPoint2 = Point(coordinate: controlPointCoordinate2, id: numberOfPoints)
        
        points[position].controlPoint1 = controlPoint1
        points[position].controlPoint2 = controlPoint2
        
        controlPoints.append(points[position].controlPoint1!)
        controlPoints.append(points[position].controlPoint2!)
        
        setNewIntersectionPoint(p1: points[position-1], p2: points[position])

    }
    
    //TODO: moveControlPoint
    
    //now unused
    func determineIntersectionY(normalizedXVal: CGFloat, y1: CGFloat, y2: CGFloat, y3: CGFloat) -> CGFloat{
        //pow(1-t,2) * y1 + 2 * (1-t) * t * y2 + pow(t,2) * y3
        return pow(1 - normalizedXVal, 2) * y1 + 2 * (1 - normalizedXVal) * 0.5 * y2 + pow(normalizedXVal, 2) * y3
    }
    
    func determineIntersectionY(x: CGFloat, y1: CGFloat, y2: CGFloat, y3: CGFloat, y4: CGFloat) -> CGFloat{
        // P =      (1−t)^3   * y1 + 3   (1−t)^2        * t * y2 + 3(1−t)      * t^2       * P3 + t^3       * P4
        return pow((1 - x),3) * y1 + 3 * pow((1 - x),2) * x * y2 + 3 * (1 - x) * pow(x, 2) * y3 + pow(x, 3) * y4
    }
    
    //Got a Weird error here
    func determinePointPlacement(_ newPointCoordinate: CGPoint) -> Int {
        for n in 0...(numberOfPoints - 1) {
            if(newPointCoordinate.x < points[n].coordinate.x){
                return n
            }
        }
        return -1
    }
    
    func distanceBetweenTwoPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat{
        let xDist = p1.x - p2.x
        let yDist = p1.y - p2.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func deleteCheck(){
        if(!isNewPoint){
            if( (selectedPosition == 0) || (selectedPosition == points.count - 1) ){
                print("found an edge case")
            }
            else{
                deleteSelectedPoint()
            }
        }
    }
    
    func deleteSelectedPoint(){
        points.remove(at: selectedPosition!)
        controlPoints.removeAll()
        resetControlPoint(selectedPosition!)
        selectedPoint = points[selectedPosition! - 1]
        selectedPosition = selectedPosition! - 1
        lockMove = true
    }
    
    public class Point: Identifiable {
        public var id: Int
        var coordinate: CGPoint

        init(x: CGFloat, y: CGFloat, id: Int){
            self.coordinate = CGPoint(x: x, y: y)
            self.id = id
        }
        init(coordinate: CGPoint, id: Int){
            self.coordinate = coordinate
            self.id = id
        }
    }
    
    public class PathPoint: Point{
        var controlPoint1: Point?
        var controlPoint2: Point?
        var intersectionPoint: Point?
    }
}

public enum PointType {
    case path, control, end
    var name: String {
        return "\(self)"
    }
}

extension CGPoint {

    mutating func move(x:CGFloat? = nil, y:CGFloat? = nil) -> CGPoint {
        if let x = x {
            self.x += x
        }

        if let y = y {
            self.y += y
        }

        return self
    }
    
    mutating func move(x:CGFloat, y:CGFloat, minMax: [CGFloat]) -> CGPoint {
        self.x += x

        self.y += y

        return self
    }

    mutating func up(y:CGFloat) -> CGPoint {
        return move(y: -y)
    }

    mutating func down(y:CGFloat) -> CGPoint {
        return move(y: y)
    }

    mutating func left(x:CGFloat) -> CGPoint {
        return move(x: -x)
    }

    mutating func right(x:CGFloat) -> CGPoint {
        return move(x: x)
    }
}
