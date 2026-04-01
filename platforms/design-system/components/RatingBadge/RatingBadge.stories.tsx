import type { Meta, StoryObj } from "@storybook/react";
import { RatingBadge } from "./RatingBadge";

const meta: Meta<typeof RatingBadge> = {
  component: RatingBadge,
  title: "Components/RatingBadge",
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof RatingBadge>;

export const Excellent: Story = {
  args: {
    rating: 4.8,
    count: 2450,
    size: "md",
  },
};

export const Good: Story = {
  args: {
    rating: 3.9,
    count: 1250,
  },
};

export const Average: Story = {
  args: {
    rating: 2.7,
    count: 340,
  },
};

export const Poor: Story = {
  args: {
    rating: 1.5,
    count: 89,
  },
};

export const NoCount: Story = {
  args: {
    rating: 4.2,
  },
};

export const Sizes: Story = {
  render: () => (
    <div style={{ display: "flex", gap: "16px", flexDirection: "column" }}>
      <RatingBadge rating={4.2} count={500} size="sm" />
      <RatingBadge rating={4.2} count={500} size="md" />
      <RatingBadge rating={4.2} count={500} size="lg" />
    </div>
  ),
};
