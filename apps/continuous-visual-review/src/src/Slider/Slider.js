import React, { PureComponent } from 'react'

import './Slider.css'


class Slider extends PureComponent {

  state = {
    widthContainer: '50%',
    isMouseDown: false,
  }

  getMousePosition(event) {
    const absolutePosition = event.currentTarget.getBoundingClientRect()

    return {
      x: event.clientX - absolutePosition.left,
      y: event.clientY - absolutePosition.top,
    }
  }

  handleMouseMove = (event) => {
    if (this.state.isMouseDown) {
      const mousePosition = this.getMousePosition(event)
      const widthCanvas = event.currentTarget.clientWidth

      const width = mousePosition.x / widthCanvas * 100

      this.setState({
        widthContainer: Math.min(95, Math.max(width, 5)) + '%'
      })
    }
  }

  handleMouseDown = () => { this.setState({isMouseDown: true}) }
  handleMouseUp = () => { this.setState({isMouseDown: false}) }
  handleMouseLeave = (event) => {
    this.handleMouseMove(event)
    this.handleMouseUp()
  }

  render() {
    const {
      imgLeft,
      imgRight,
    } = this.props

    return (
      <div
        className="image-slider"
        onMouseMove={this.handleMouseMove}
        onMouseDown={this.handleMouseDown}
        onMouseUp={this.handleMouseUp}
        onMouseLeave={this.handleMouseLeave}
        >
        <div className="selector"></div>
        <div className="container-left-img" style={{
          width: this.state.widthContainer,
          backgroundImage: `url(${imgLeft})`
        }}></div>
        <img src={imgRight} alt="comparator (left/right)" />
      </div>
    )
  }
}


export default Slider
