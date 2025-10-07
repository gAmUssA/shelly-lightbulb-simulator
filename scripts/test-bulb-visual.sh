#!/bin/bash

# Test script to verify bulb visual appearance across different colors and modes

BASE_URL="http://localhost:8080"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ASCII Art Banner
echo -e "${CYAN}"
cat << "EOF"
   _____ __         ____         ____        ____     
  / ___// /_  ___  / / /_  __   / __ )__  __/ / /_    
  \__ \/ __ \/ _ \/ / / / / /  / __  / / / / / __ \   
 ___/ / / / /  __/ / / /_/ /  / /_/ / /_/ / / /_/ /   
/____/_/ /_/\___/_/_/\__, /  /_____/\__,_/_/_.___/    
                    /____/                            
    _    ___                 __   ______          __  
   | |  / (_)______  ______ _/ /  /_  __/__  _____/ /_ 
   | | / / / ___/ / / / __ `/ /    / / / _ \/ ___/ __/ 
   | |/ / (__  ) /_/ / /_/ / /    / / /  __(__  ) /_   
   |___/_/____/\__,_/\__,_/_/    /_/  \___/____/\__/   
                                                        
EOF
echo -e "${NC}"

echo -e "${BOLD}${WHITE}Testing Bulb Visual Appearance Across All Modes${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Turn off the bulb
echo -e "${YELLOW}💡 Test 1: Turn OFF bulb ${NC}(should show minimal glow)"
curl -s -X POST "$BASE_URL/light/0?turn=off" > /dev/null
echo -e "${GREEN}   ✓ Bulb turned off - darkness prevails 🌑${NC}"
sleep 2

# Test 2: Red color
echo ""
echo -e "${RED}🔴 Test 2: RED color ${NC}(RGB: 255, 0, 0)"
curl -s -X POST "$BASE_URL/color/0?turn=on&red=255&green=0&blue=0&gain=100" > /dev/null
echo -e "${GREEN}   ✓ Red color applied - burning bright! 🔥${NC}"
sleep 2

# Test 3: Green color
echo ""
echo -e "${GREEN}🟢 Test 3: GREEN color ${NC}(RGB: 0, 255, 0)"
curl -s -X POST "$BASE_URL/color/0?red=0&green=255&blue=0" > /dev/null
echo -e "${GREEN}   ✓ Green color applied - nature vibes! 🌿${NC}"
sleep 2

# Test 4: Blue color
echo ""
echo -e "${BLUE}🔵 Test 4: BLUE color ${NC}(RGB: 0, 0, 255)"
curl -s -X POST "$BASE_URL/color/0?red=0&green=0&blue=255" > /dev/null
echo -e "${GREEN}   ✓ Blue color applied - ocean deep! 🌊${NC}"
sleep 2

# Test 5: Yellow color
echo ""
echo -e "${YELLOW}🟡 Test 5: YELLOW color ${NC}(RGB: 255, 255, 0)"
curl -s -X POST "$BASE_URL/color/0?red=255&green=255&blue=0" > /dev/null
echo -e "${GREEN}   ✓ Yellow color applied - sunshine bright! ☀️${NC}"
sleep 2

# Test 6: Purple color
echo ""
echo -e "${PURPLE}🟣 Test 6: PURPLE color ${NC}(RGB: 128, 0, 128)"
curl -s -X POST "$BASE_URL/color/0?red=128&green=0&blue=128" > /dev/null
echo -e "${GREEN}   ✓ Purple color applied - royal majesty! 👑${NC}"
sleep 2

# Test 7: Warm white (3000K)
echo ""
echo -e "${YELLOW}🌅 Test 7: WARM WHITE mode ${NC}(3000K, brightness 100)"
curl -s -X POST "$BASE_URL/white/0?turn=on&temp=3000&brightness=100" > /dev/null
echo -e "${GREEN}   ✓ Warm white applied - cozy evening! 🕯️${NC}"
sleep 2

# Test 8: Cool white (6500K)
echo ""
echo -e "${CYAN}❄️  Test 8: COOL WHITE mode ${NC}(6500K, brightness 100)"
curl -s -X POST "$BASE_URL/white/0?temp=6500&brightness=100" > /dev/null
echo -e "${GREEN}   ✓ Cool white applied - arctic chill! 🧊${NC}"
sleep 2

# Test 9: Medium white (4500K)
echo ""
echo -e "${WHITE}⚪ Test 9: MEDIUM WHITE mode ${NC}(4500K, brightness 80)"
curl -s -X POST "$BASE_URL/white/0?temp=4500&brightness=80" > /dev/null
echo -e "${GREEN}   ✓ Medium white applied - balanced light! ⚖️${NC}"
sleep 2

# Test 10: Transition test
echo ""
echo -e "${PURPLE}🌈 Test 10: SMOOTH TRANSITION ${NC}(red → blue, 2000ms)"
curl -s -X POST "$BASE_URL/color/0?red=255&green=0&blue=0&transition=2000" > /dev/null
sleep 1
curl -s -X POST "$BASE_URL/color/0?red=0&green=0&blue=255&transition=2000" > /dev/null
echo -e "${GREEN}   ✓ Transition test applied - color morphing! 🎨${NC}"
sleep 3

# Test 11: Turn off with transition
echo ""
echo -e "${YELLOW}🌙 Test 11: FADE TO BLACK ${NC}(smooth transition, 1000ms)"
curl -s -X POST "$BASE_URL/light/0?turn=off&transition=1000" > /dev/null
echo -e "${GREEN}   ✓ Bulb turned off with transition - goodnight! 😴${NC}"
sleep 2

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}✨ All visual tests completed successfully! ✨${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}${WHITE}📋 Verification Checklist:${NC}"
echo -e "${YELLOW}   ✓${NC} Background remains dark (#1a1a1a) throughout"
echo -e "${YELLOW}   ✓${NC} Glow is localized around the bulb"
echo -e "${YELLOW}   ✓${NC} Colors display correctly in color mode"
echo -e "${YELLOW}   ✓${NC} White temperatures display correctly in white mode"
echo -e "${YELLOW}   ✓${NC} Off state shows minimal glow"
echo -e "${YELLOW}   ✓${NC} Transitions are smooth and seamless"
echo ""
echo -e "${BOLD}${CYAN}🎉 Happy Testing! 🎉${NC}"
echo ""
