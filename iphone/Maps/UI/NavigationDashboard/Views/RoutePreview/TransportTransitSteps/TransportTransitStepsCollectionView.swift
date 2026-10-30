final class TransportTransitStepsCollectionView: UICollectionView {
  var steps: [MWMRouterTransitStepInfo] = [] {
    didSet {
      updateDisplayedSteps()
    }
  }

  private var displayedSteps = [MWMRouterTransitStepInfo]()
  private var displayedWidth: CGFloat = 0

  override func layoutSubviews() {
    if displayedWidth != bounds.width {
      updateDisplayedSteps()
    }
    super.layoutSubviews()
  }

  override var frame: CGRect {
    didSet {
      collectionViewLayout.invalidateLayout()
    }
  }

  override var bounds: CGRect {
    didSet {
      collectionViewLayout.invalidateLayout()
    }
  }

  init(layout: UICollectionViewLayout) {
    super.init(frame: .zero, collectionViewLayout: layout)
    setup()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  private func setup() {
    dataSource = self
    [TransportTransitIntermediatePoint.self, TransportTransitPedestrian.self,
     TransportTransitTrain.self, TransportRuler.self].forEach {
      register(cellClass: $0)
    }
  }

  private func cellClass(step: MWMRouterTransitStepInfo) -> TransportTransitCell.Type {
    switch step.type {
    case .intermediatePoint: return TransportTransitIntermediatePoint.self
    case .pedestrian: return TransportTransitPedestrian.self
    case .train, .subway, .lightRail, .monorail, .tram, .bus,
         .ferry, .cableTram, .aerialLift, .funicular, .airService, .waterService:
      return TransportTransitTrain.self
    case .ruler: return TransportRuler.self
    }
  }

  private func updateDisplayedSteps() {
    displayedWidth = bounds.width
    var cursor = TransportTransitFlowLayout.Cursor(width: displayedWidth)
    displayedSteps = steps.enumerated().flatMap { index, step -> [MWMRouterTransitStepInfo] in
      let hasFollowingStep = index + 1 < steps.count
      var fragments = [step]
      if displayedWidth > 0, cellClass(step: step) == TransportTransitTrain.self {
        let groups = TransportTransitTrain.numberGroups(step.number, maximumWidth: displayedWidth,
                                                        firstRowWidth: cursor.remainingWidth,
                                                        hasFollowingStep: hasFollowingStep)
        if groups.count > 1 {
          fragments = groups.map { number in
            let continuation = MWMRouterTransitStepInfo()
            continuation.type = step.type
            continuation.number = number
            continuation.color = step.color
            continuation.distance = step.distance
            continuation.distanceUnits = step.distanceUnits
            continuation.intermediateIndex = step.intermediateIndex
            return continuation
          }
        }
      }
      for (fragmentIndex, fragment) in fragments.enumerated() {
        let size = cellClass(step: fragment).estimatedCellSize(step: fragment)
        _ = cursor.append(size: size, hasFollowingStep: hasFollowingStep || fragmentIndex + 1 < fragments.count)
      }
      return fragments
    }
    reloadData()
  }

  func estimatedCellSize(item: Int) -> CGSize {
    let step = displayedSteps[item]
    return cellClass(step: step).estimatedCellSize(step: step)
  }
}

extension TransportTransitStepsCollectionView: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    displayedSteps.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let item = indexPath.item
    let step = displayedSteps[item]
    let cellClass = cellClass(step: step)
    let cell = collectionView.dequeueReusableCell(withCellClass: cellClass, indexPath: indexPath) as! TransportTransitCell
    cell.config(step: step)
    return cell
  }
}
