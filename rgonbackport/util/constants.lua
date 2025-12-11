local mod = RgonBackport

RgonBackport.SlotState = {
    IDLE = 1,
    CHOICE = 2, -- Shell Game & Hell Game only, choose a skull
    REWARD = 2,
    DESTROYED = 3,
    PAYOUT = 4,
    REWARD_SHELL_GAME = 5,
    REWARD_HELL_GAME = 5,
}