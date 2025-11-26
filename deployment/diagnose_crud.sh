#!/bin/bash

# Backend CRUD Diagnostic Script
# Run this on the server to diagnose CRUD issues

echo "========================================="
echo "Backend CRUD Diagnostic Tool"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Check Laravel logs
echo -e "${YELLOW}[1/8] Checking Laravel logs...${NC}"
if [ -f "storage/logs/laravel.log" ]; then
    echo -e "${GREEN}✓ Log file exists${NC}"
    echo "Last 10 errors:"
    tail -n 50 storage/logs/laravel.log | grep -i "error\|exception\|sqlstate" | tail -n 10
else
    echo -e "${RED}✗ Log file not found${NC}"
fi
echo ""

# 2. Check file permissions
echo -e "${YELLOW}[2/8] Checking file permissions...${NC}"
STORAGE_PERM=$(stat -c "%a" storage 2>/dev/null || stat -f "%A" storage 2>/dev/null)
LOGS_PERM=$(stat -c "%a" storage/logs 2>/dev/null || stat -f "%A" storage/logs 2>/dev/null)

if [ "$STORAGE_PERM" = "755" ] || [ "$STORAGE_PERM" = "775" ]; then
    echo -e "${GREEN}✓ storage/ permissions OK ($STORAGE_PERM)${NC}"
else
    echo -e "${RED}✗ storage/ permissions incorrect ($STORAGE_PERM)${NC}"
    echo "  Run: chmod -R 755 storage"
fi

if [ "$LOGS_PERM" = "755" ] || [ "$LOGS_PERM" = "775" ]; then
    echo -e "${GREEN}✓ storage/logs/ permissions OK ($LOGS_PERM)${NC}"
else
    echo -e "${RED}✗ storage/logs/ permissions incorrect ($LOGS_PERM)${NC}"
    echo "  Run: chmod -R 775 storage/logs"
fi
echo ""

# 3. Check database connection
echo -e "${YELLOW}[3/8] Checking database connection...${NC}"
php artisan db:show 2>&1 | head -n 5
echo ""

# 4. Check .env configuration
echo -e "${YELLOW}[4/8] Checking .env configuration...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env file exists${NC}"
    echo "Database config:"
    grep "^DB_" .env | sed 's/DB_PASSWORD=.*/DB_PASSWORD=***HIDDEN***/'
else
    echo -e "${RED}✗ .env file not found${NC}"
fi
echo ""

# 5. Check storage link
echo -e "${YELLOW}[5/8] Checking storage link...${NC}"
if [ -L "public/storage" ]; then
    echo -e "${GREEN}✓ Storage link exists${NC}"
    ls -la public/storage | head -n 1
else
    echo -e "${RED}✗ Storage link missing${NC}"
    echo "  Run: php artisan storage:link"
fi
echo ""

# 6. Check PHP version
echo -e "${YELLOW}[6/8] Checking PHP version...${NC}"
PHP_VERSION=$(php -v | head -n 1)
echo "$PHP_VERSION"
if [[ "$PHP_VERSION" == *"8.1"* ]] || [[ "$PHP_VERSION" == *"8.2"* ]] || [[ "$PHP_VERSION" == *"8.3"* ]]; then
    echo -e "${GREEN}✓ PHP version OK${NC}"
else
    echo -e "${YELLOW}⚠ PHP version might be outdated${NC}"
fi
echo ""

# 7. Check required directories
echo -e "${YELLOW}[7/8] Checking required directories...${NC}"
REQUIRED_DIRS=("storage/framework/sessions" "storage/framework/views" "storage/framework/cache" "bootstrap/cache")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ $dir exists${NC}"
    else
        echo -e "${RED}✗ $dir missing${NC}"
        echo "  Run: mkdir -p $dir && chmod 775 $dir"
    fi
done
echo ""

# 8. Check Models fillable
echo -e "${YELLOW}[8/8] Checking Models...${NC}"
if [ -d "app/Models" ]; then
    MODEL_COUNT=$(ls -1 app/Models/*.php 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Found $MODEL_COUNT models${NC}"
    
    # Check if Movie model has fillable
    if [ -f "app/Models/Movie.php" ]; then
        if grep -q "fillable" app/Models/Movie.php; then
            echo -e "${GREEN}✓ Movie model has \$fillable property${NC}"
        else
            echo -e "${RED}✗ Movie model missing \$fillable property${NC}"
        fi
    fi
else
    echo -e "${RED}✗ app/Models directory not found${NC}"
fi
echo ""

# Summary
echo "========================================="
echo "Diagnostic Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review any errors above"
echo "2. Check storage/logs/laravel.log for details"
echo "3. Run: php artisan optimize:clear"
echo "4. Test CRUD operations in admin panel"
echo ""
