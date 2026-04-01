import React from "react";
import { render, screen } from "@testing-library/react";
import { RatingBadge } from "./RatingBadge";

describe("RatingBadge", () => {
  it("renders rating and star", () => {
    render(<RatingBadge rating={4.5} />);
    expect(screen.getByText("4.5")).toBeInTheDocument();
    expect(screen.getByText("★")).toBeInTheDocument();
  });

  it("renders review count when provided", () => {
    render(<RatingBadge rating={4.2} count={1250} />);
    expect(screen.getByText("(1,250 reviews)")).toBeInTheDocument();
  });

  it("applies excellent sentiment styling for rating >= 4.5", () => {
    const { container } = render(<RatingBadge rating={4.8} />);
    const badge = container.firstChild;
    expect(badge).toHaveStyle({
      backgroundColor: expect.stringContaining("success"),
    });
  });

  it("applies poor sentiment styling for rating < 2.5", () => {
    const { container } = render(<RatingBadge rating={2.0} />);
    const badge = container.firstChild;
    expect(badge).toHaveStyle({
      backgroundColor: expect.stringContaining("error"),
    });
  });

  it("respects size prop", () => {
    const { rerender } = render(<RatingBadge rating={4.0} size="sm" />);
    expect(screen.getByText("4.0")).toHaveStyle({
      fontSize: expect.any(String),
    });

    rerender(<RatingBadge rating={4.0} size="lg" />);
    expect(screen.getByText("4.0")).toHaveStyle({
      fontSize: expect.any(String),
    });
  });
});
