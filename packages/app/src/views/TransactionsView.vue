<template>
  <div>
    <div class="head-block">
      <Breadcrumbs :items="breadcrumbItems" />
      <SearchForm class="search-form" />
    </div>
    <h1>{{ t('transactionsView.title') }}</h1>
    <TransactionsTable
      class="transactions-container"
      use-query-pagination
      :data-testid="$testId.transactionsTable"
      :search-params="{ address: user.loggedIn ? user.address : undefined }"
    >
      <template #not-found>
        <TransactionEmptyState>
          <template #title>
            {{ t('transactions.table.notFound') }}
          </template>
          <template #description>
            {{ t('transactions.table.notFound') }}
          </template>
        </TransactionEmptyState>
      </template>
    </TransactionsTable>
  </div>
</template>
<script setup lang="ts">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

import SearchForm from '@/components/SearchForm.vue';
import Breadcrumbs, {
  type BreadcrumbItem,
} from '@/components/common/Breadcrumbs.vue';
import TransactionsTable from '@/components/transactions/Table.vue';
import TransactionEmptyState from '@/components/transactions/TransactionEmptyState.vue';

import useContext from '@/composables/useContext';

const { t } = useI18n();

const breadcrumbItems = computed((): BreadcrumbItem[] => [
  {
    text: t('breadcrumbs.home'),
    to: { name: 'home' },
  },
  {
    text: `${t('transactionsView.title')}`,
  },
]);

const { user } = useContext();
</script>

<style lang="scss" scoped>
.head-block {
  @apply mb-8 flex flex-col-reverse justify-between lg:mb-10 lg:flex-row;

  .search-form {
    @apply mb-6 w-full max-w-[26rem] lg:mb-0;
  }
}
.transactions-container {
  @apply mt-8;
}
</style>
